package com.dsideal.space.outputzip.getfile;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class GetJpg {
    public InputStream testImg1() throws IOException {
        String url = "http://10.10.14.199/dsideal_yy/space/_Q5_resource";
        InputStream murl = new URL(url).openStream();


//        BufferedImage sourceImg = ImageIO.read(murl);
//        System.out.println(sourceImg.getWidth());   // 源图宽度
//        System.out.println(sourceImg.getHeight());   // 源图高度
        return murl;
    }
    public String getFileName() throws IOException{
        String url = "http://10.10.14.199/dsideal_yy/space/_Q5_resource";
        String filename = "";
        boolean isok = false;
        // 从UrlConnection中获取文件名称
        try {
            URL myURL = new URL(url);

            URLConnection conn = myURL.openConnection();
            if (conn == null) {
                return null;
            }
            Map<String, List<String>> hf = conn.getHeaderFields();
            if (hf == null) {
                return null;
            }
            Set<String> key = hf.keySet();
            if (key == null) {
                return null;
            }
            // Log.i("test", "getContentType:" + conn.getContentType() + ",Url:"
            // + conn.getURL().toString());
            for (String skey : key) {
                List<String> values = hf.get(skey);
                for (String value : values) {
                    String result;
                    try {
                        result = new String(value.getBytes("ISO-8859-1"), "GBK");
                        int location = result.indexOf("filename");
                        if (location >= 0) {
                            result = result.substring(location
                                    + "filename".length());
                            filename = result
                                    .substring(result.indexOf("=") + 1);
                            isok = true;
                        }
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }// ISO-8859-1 UTF-8 gb2312
                }
                if (isok) {
                    break;
                }
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return filename;
    }
}
