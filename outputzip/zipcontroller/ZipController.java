package com.dsideal.space.outputzip.zipcontroller;

import com.dsideal.space.outputzip.getfile.GetFile;
import com.dsideal.space.outputzip.getfile.GetUrlPngFile;
import com.dsideal.space.qroutput.dao.QrDao;
import com.dsideal.space.qroutput.entity.ResourceInfo;
import com.dsideal.space.qroutput.entity.Scheme;
import com.dsideal.space.qroutput.qrcontroller.QROutputController;
import com.dsideal.space.qroutput.util.CreateResInfoWb;
import com.jfinal.core.Controller;
import org.apache.commons.codec.binary.Base64;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipOutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.InetAddress;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Map;

//压缩包输出
public class ZipController extends Controller {
    public void index() throws IOException {
        long go = System.currentTimeMillis();
        String fileName = "List";
        HttpServletResponse response = getResponse();
        HttpServletRequest request = getRequest();
        response.setHeader("Connection", "close");
        response.setHeader("Content-Type", "application/vnd.ms-excel;charset=UTF-8");
        String filename = System.currentTimeMillis() + fileName + ".zip";
//        filename = encodeFileName(request, filename);
        System.out.println("index =" + encodeFileName(request, "aaa"));
        response.setHeader("Content-Disposition", "attachment;filename=" + filename);
//        response.setHeader("Content-Disposition", "attachment;filename=" + "2131321321321313211654646546456adas.zip");
        OutputStream out = null;
        out = response.getOutputStream();
        ZipOutputStream zos = new ZipOutputStream(out);
        InputStream is = null;

        try {
            // create byte buffer
            byte[] buffer = new byte[2048];
            GetFile gf = new GetFile();
            GetUrlPngFile gupf = new GetUrlPngFile();
            InetAddress address = InetAddress.getLocalHost();
            String ip = address.getHostAddress();
//            String url2 = "http://"+ip+"/dsideal_yy/space/_h5_resource";
            QrDao qd = new QrDao();
            Map<String, String> urlPngList = qd.getQrUrl();
            long starttime = System.currentTimeMillis();
            for (Map.Entry<String, String> entry : urlPngList.entrySet()) {
                try {//返回错误二维码地址。
                    zipPngAction(entry.getKey(), is, zos, gupf, buffer, entry.getValue());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            long endtime = System.currentTimeMillis();
            System.out.println("osward");
            System.out.println(endtime - starttime);
            System.out.println("osward");

            zipAction(zos);
        } catch (Exception ioe) {
            ioe.printStackTrace();
        } finally {
            zos.closeEntry();
            zos.close();
            if (is != null)
                is.close();
        }
        renderNull();
        long back = System.currentTimeMillis();
        System.out.println("osward1");
        System.out.println(go - back);
        System.out.println("osward1");
    }

    private void zipAction(ZipOutputStream zos) throws Exception {
//        byte[] buffer = new byte[1024];

//        is = gf.getFileInputStream(url);
//        String fileName1 = gf.getFileName(url);
////        System.out.println(fileName1);
//        ZipEntry entry = new ZipEntry(vo.getId() + ".xls");
//        zipOutputStream.putNextEntry(entry);
//        book.write(zipOutputStream);


        zos.putNextEntry(new ZipEntry("QrList.xls"));
        outputWb().write(zos);
    }

    private void zipPngAction(String url, InputStream is, ZipOutputStream zos, GetUrlPngFile gf, byte[] buffer, String filename) throws Exception {
        is = gf.getFileInputStream(url);
        if (is != null) {
            String fileName1 = filename;
            zos.putNextEntry(new ZipEntry(fileName1));
            int length;
            while ((length = is.read(buffer)) > 0) {
                zos.write(buffer, 0, length);
            }
        }
    }


    private int encodeFileName(HttpServletRequest request, String fileName) throws UnsupportedEncodingException {
        String agent = request.getHeader("USER-AGENT");
//        if (null != agent && -1 != agent.indexOf("MSIE")) {
//            return URLEncoder.encode(fileName, "UTF-8");
//        } else if (null != agent && -1 != agent.indexOf("Mozilla")) {
//            return "=?UTF-8?B?"+ (new String(Base64.encodeBase64(fileName.getBytes("UTF-8")))) + "?=";
//        } else {
//            return fileName;
//        }
        return agent.indexOf("MSIE");
    }

    private HSSFWorkbook outputWb() throws IOException {
        HSSFWorkbook wb1 = null;

        QrDao qd = new QrDao();
        ArrayList<ResourceInfo> resourceinfos = qd.getResourceInfoList();
        ArrayList<Scheme> schemes = new ArrayList<Scheme>();
//        Scheme scheme = new Scheme("版本id","册id","章id","节id","版本名","册名","章名","节名");
        Scheme scheme = new Scheme("版本名", "册名", "章名", "节名");

        schemes.add(scheme);
//        ResourceInfo user1 = new ResourceInfo("序号","学段ID","学段名","学科ID","学科名",schemes,"所属分类ID","分类名称","资源名","缩略图ID+扩展名","压缩文件ID+扩展名","需要解压状态","解压状态","http全路径","二维码文件ID+扩展名","创建时间","更新时间");
        ResourceInfo user1 = new ResourceInfo("序号", "学段名", "学科名", schemes, "分类名称", "资源名", "缩略图ID+扩展名", "压缩文件ID+扩展名", "http全路径", "二维码文件ID+扩展名", "创建时间", "更新时间");

        resourceinfos.add(0, user1);
        CreateResInfoWb criw = new CreateResInfoWb();
        wb1 = criw.getWb(resourceinfos);
        return wb1;
    }
}
