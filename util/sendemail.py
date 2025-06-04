import smtplib
from email.message import EmailMessage
import os
import argparse

def send_email(smtp_server, smtp_port, username, password, to_addrs,
               subject, body, attachment_path=None, cc_addrs=None, bcc_addrs=None, ssl=True):   

    msg = EmailMessage()
    msg['From'] = username if username else "user@localhost"
    msg['To'] = ', '.join(to_addrs)
    msg['Subject'] = subject

    if cc_addrs:
        msg['Cc'] = ', '.join(cc_addrs)
    msg.set_content(body)

    if attachment_path:
        with open(attachment_path, 'rb') as f:
            file_data = f.read()
            file_name = os.path.basename(attachment_path)
        msg.add_attachment(file_data, maintype='application', subtype='octet-stream', filename=file_name)

    all_recipients = to_addrs + (cc_addrs or []) + (bcc_addrs or [])

    if ssl:
        server = smtplib.SMTP_SSL(smtp_server, smtp_port)
    else:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.ehlo()
        try:
            server.starttls()
        except smtplib.SMTPException:
            pass  # TLS may not be supported

    if username and password:
        server.login(username, password)

    server.send_message(msg, from_addr=msg['From'], to_addrs=all_recipients)
    server.quit()    
    print("📬 Email sent!")

def parse_args():
    parser = argparse.ArgumentParser(description="Send an email with optional attachment, cc, and bcc.")
    parser.add_argument('--smtp', required=True, help='SMTP server (e.g., smtp.gmail.com)')
    parser.add_argument('--port', type=int, default=465, help='SMTP port (default: 465)')
    parser.add_argument('--user',  help='SMTP username/email address')
    parser.add_argument('--password', help='SMTP password or app password')
        
    parser.add_argument('--no-ssl', action='store_false', help='Use plain SMTP instead of SSL')
    parser.add_argument('--to', nargs='+', required=True, help='Recipient email address(es)')
    parser.add_argument('--cc', nargs='*', help='CC email address(es)', default=[])
    parser.add_argument('--bcc', nargs='*', help='BCC email address(es)', default=[])
    parser.add_argument('--subject', required=True, help='Email subject')
    parser.add_argument('--body', required=True, help='Path to text file containing the email body')
    parser.add_argument('--attach', help='Path to a file to attach')

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    send_email(
        smtp_server=args.smtp,
        smtp_port=args.port,
        username=args.user,
        password=args.password,
        to_addrs=args.to,
        subject=args.subject,
        body=args.body,
        attachment_path=args.attach,
        cc_addrs=args.cc,
        bcc_addrs=args.bcc,
        ssl=args.no_ssl
    )