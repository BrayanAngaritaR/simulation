 /*
Este código obtiene las noticias de El Tiempo de Medellín a través de RSS
Fecha: 23/09/2019
Realizado por: Brayan Angarita Rivera
 */

PImage webImg;

String url;   
XML imagen;
XML rss;  
XML[] titleXMLElements;
XML imgencita;
int k ;

void setup(){
url = "https://www.eltiempo.com/rss/colombia_medellin.xml";   
imagen = loadXML(url);
rss = loadXML(url);  
titleXMLElements = rss.getChildren("channel/item/title"); 
imgencita = rss.getChild("channel/item/enclosure");
println(imgencita.getString("url"));
webImg = loadImage(imgencita.getString("url"));

//size(800,400);

}

void draw(){
image(webImg, 0, 0);

k=0;
for (int i = 0; i < titleXMLElements.length; i++) { 
    String title = titleXMLElements[i].getContent();
    fill(85,107,47);
    text(i + ": " + title,10,k+=15);
}  

}
