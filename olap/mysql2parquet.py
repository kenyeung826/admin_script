#!/usr/bin/python
# -*- coding: utf-8 -*-

import zstandard as zstd
import sqlparse
import re
import io
import os
import pandas as pd
from fastparquet import write
import argparse
import csv
import io

def parse_sql_to_parquet(statement, output_path):              
    
    d = []
    
    parsed = sqlparse.parse(statement)
        
    if not parsed or not parsed[0].tokens:
        return

    parsed = parsed[0]   
        
    if parsed.get_type() == 'INSERT':        
        values_part = re.search(r'VALUES\s*\((.+)\)', str(parsed), re.DOTALL)
        if values_part:
            values = values_part.group(1).split('),(')
            for value in values:
                value = value.strip('()')
                csv_reader = csv.reader(io.StringIO(value), skipinitialspace=True, quotechar="'", delimiter=',')
                parsed_row = next(csv_reader)
                if len(parsed_row) == 17:  # Ensure the row has the correct number of columns
                    d.append([v.strip().strip("'") for v in parsed_row])
                    print(f"Normal row: {parsed_row}\n")   
                else:
                    print(f"Skipping malformed row: {parsed_row}\n")                                    
    if d:
        df = pd.DataFrame(d, columns=["id", "user_id", "content", "create_date", "create_time"])    
        df = df.astype({
            "id": "int64",
            "user_id": "int64",            
            "content": "string",            
            "create_date": "datetime64",  # or "datetime64[ns]" if you want to parse dates
            "create_time": "datetime64"   # or "datetime64[ns]" if you want to parse times
        })
        write(output_path, df, compression = "GZIP", append = os.path.exists(output_path), object_encoding='utf8')        

def read_zst_file(file_path, output_path):    
    with open(file_path, 'rb') as file:
        dctx = zstd.ZstdDecompressor()
        with dctx.stream_reader(file) as reader:            
            with io.TextIOWrapper(reader, encoding='utf-8') as text_stream:                
                for line in text_stream:                                        
                    parse_sql_to_parquet(line, output_path)                                        
                    

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Process a .zst SQL dump and convert it to Parquet files.")
    parser.add_argument('file_path', type=str, help="Path to the .zst SQL dump file.")
    parser.add_argument('output_path', type=str, help="Directory to save the Parquet files.")
    args = parser.parse_args()

    file_path = args.file_path
    output_path = args.output_path
    
    if os.path.exists(file_path):        
        output_dir = os.path.dirname(output_path)
        os.makedirs(output_dir, exist_ok=True)
        content = read_zst_file(file_path, output_path)


