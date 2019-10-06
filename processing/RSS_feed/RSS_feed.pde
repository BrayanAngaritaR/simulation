PImage webImg;

// Load RSS feed   
String url = "https://www.eltiempo.com/rss/colombia_medellin.xml";   
// XMLElement rss = new XMLElement(this, url);   
XML rss = loadXML(url);  
XML imagen = loadXML(url);

// Get title of each element   
// XMLElement[] titleXMLElements = rss.getChildren("channel/item/title"); 
XML[] titleXMLElements = rss.getChildren("channel/item/title"); 
XML imgencita = rss.getChild("channel/item/enclosure");
//String ruta = str(imgencita);
//String root = split(imgencita,'=');
println(imgencita.getString("url")); 

//XML[] titleXMLImg = rss.getChildren("channel/item/enclosure:url"); 
for (int i = 0; i < titleXMLElements.length; i++) {   
    String title = titleXMLElements[i].getContent();   
    println(i + ": " + title);
}  
println("---");
webImg = loadImage(imgencita.getString("url"));
image(webImg, 0, 0);


//for (int i = 0; i < titleXMLImg.length; i++) {   
//    String title2 = titleXMLImg[i].getContent();   
//    println(i + ": " + title2);  
//    //String enclosure  = titleXMLElements[i].getContent(); 
//    //webImg = loadImage(enclosure, "png");
//    //background(0);
//   //image(webImg, 0, 0);
//}  
