# netres_project

Resilience of Public Transportation Networks

Report available at:\
https://luckerma.github.io/netres_project/

## Report (Quarto)

### Preview Report (HTML)

```bash
quarto preview ./report/
```

### Render Report (PDF)

```bash
quarto render ./report/ --to pdf
```

### Render Report (IEEE PDF)

```bash
cd report/
quarto add dfolio/quarto-ieee
quarto render . --to ieee-pdf
```
