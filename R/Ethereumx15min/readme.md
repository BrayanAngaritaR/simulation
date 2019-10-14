## Graficar velas en RStudio
### Brayan Angarita

Este programa realiza las siguientes funciones:

* Obtiene velas de ETH para 15 minutos, vía CURL; realiza la petición de la API de HitBTC, para los datos correspondientes a la moneda Ethereum.

* Una vez descargados dichos datos, lo exporta a un archivo CSV. Elimina los caracteres especiales y encabezados no necesarios en el archivo.

* Luego los inserta en la base de datos mediante SQLite, en una tabla con el nombre de db_table_Ethereum.

```
install.packages("httr")
install.packages("Rtools")
require("httr")
install.packages("jsonlite")
require("jsonlite")
install.packages("RSQLite")
library("RSQLite")

query <- "https://api.hitbtc.com/api/2/public/candles/ETHBTC?period=M15"
out <- GET(url=query)

out_text <- content(out,"text")
out_text_json <- fromJSON(out_text,flatten = TRUE)
out_df <- as.data.frame(out_text_json)

get_min <- as.numeric(out_df$min)
get_max <- as.numeric(out_df$max)
get_volume <- as.numeric(out_df$volume)
```

## Obtener toda la información

```
get_info = data.frame(get_min,get_max,get_volume,volumeQuote,close,open,tiempo)

```
## Exportar datos a aun csv
```
write.table(get_info, file = "Ethereum.csv", sep = ",", row.names = F, col.names = F,quote=F)
```
## Comenzar con la graficación
```
par(mfcol = c(3,2))
```

## Llevar Datos a  SQLite
```
con <- dbConnect(RSQLite::SQLite(), ":memory:")
con
dbWriteTable(con, "db_table_Ethereum", get_info)
dbListTables(con)
dbReadTable(con, "db_table_Ethereum")
```
## Graficar todos los elementos
```
plot (open,pch=16,col=1,xlab ="tiempo(minutos)")
par(mfrow=c(2,2))
plot (open,pch=16,col=1,xlab ="tiempo(minutos)")
lines(open) /*Graficar la información con las líneas*/

plot (get_volume,pch=16,col=1,xlab ="tiempo(minutos)")
lines(get_volume)

plot (get_min,pch=16,col=1,xlab ="tiempo(minutos)")
lines(get_min)

plot (get_max,pch=16,col=1,xlab ="tiempo(minutos)")
lines(get_max)

plot (close,pch=16,col=1,xlab ="tiempo(minutos)")
lines(close)

plot (volumeQuote,pch=16,col=1,xlab ="tiempo(minutos)")
lines(volumeQuote)
```