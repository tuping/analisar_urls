## Instruções
<!-- MarkdownTOC -->

- [Instalar o wappalyzer:](#instalar-o-wappalyzer)
- [Atualizar pacotes](#atualizar-pacotes)
- [Uso](#uso)
- [Exemplo](#exemplo)

<!-- /MarkdownTOC -->

<a id="instalar-o-wappalyzer"></a>
### Instalar o wappalyzer: 
```
npm i -g wappalyzer
```

<a id="atualizar-pacotes"></a>
### Atualizar pacotes
```
npm update -g
```

<a id="uso"></a>
### Uso
```
usage: ./analisar_urls.rb [options]
* required options
    -if, --input_xlsx_file   * input file (xlsx)
    -of, --output_xlsx_file  * output file (xlsx)
    -enc, --encoding         encoding (default ISO_8859_1)
    -f, --force              force overwrite output file

other options:
    -v, --version            
    -valid_encodings         
    -h                       
```

<a id="exemplo"></a>
### Exemplo
```
./analisar_urls.rb -if=~/Documents/jad/sites_ecommerce.xlsx -of=~/Documents/jad/sites_ecommerce_out.xlsx -enc=UTF-8 -f
```

* *O arquivo deve ter uma coluna **cliente** e uma coluna **site**.*