package com.dsideal.space.outputzip.getfile;

import java.io.DataInputStream;
import java.io.InputStream;
import java.net.URL;


public class GetUrlPngFile {
    public InputStream getFileInputStream(String url){
        try {
            URL murl= new URL(url);
            InputStream dataInputStream = new DataInputStream(murl.openStream());
            return dataInputStream;
        } catch (Exception e) {
//            e.printStackTrace();
        }
//        System.out.println(murl);
        return null;
    }
//    public  static void main(String args[]){
//        String url = "http://video.edusoa.com/down/H5Res/6F/6F65F83B-5CBA-498A-216D-F3BC2FE9C440/6F65F83B-5CBA-498A-216D-F3BC2FE9C440.png";
//        try {
//            URL   murl = new URL(url);
//            System.out.println(murl);
//            InputStream dataInputStream = new DataInputStream(murl.openStream());
//            System.out.println(dataInputStream);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
}
