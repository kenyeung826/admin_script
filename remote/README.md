## Copy With parallel

### Copy files to remote host

```bash
parallel scp ${src_path:src.txt} {}:${dest_path} ::: ${host_list}
```

### Execute Command on remote host

#### command

```bash
parallel --verbose --keep-order -j 2 ssh -T {} "ls -ltr ~/" ::: ${host_list}
```

#### from file

```bash
parallel --verbose ssh -T {} "'bash -s ' < command.sh" ::: ${host_list}
```

run ssh code in command.sh
```bash
parallel --verbose  command.sh ::: ${host_list}
```

