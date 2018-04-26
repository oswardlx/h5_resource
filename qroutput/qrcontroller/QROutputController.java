package com.dsideal.space.qroutput.qrcontroller;

import com.dsideal.space.qroutput.dao.QrDao;
import com.dsideal.space.qroutput.entity.ResourceInfo;
import com.dsideal.space.examine.exceloutput.ExamineController;
import com.dsideal.space.qroutput.entity.Scheme;
import com.dsideal.space.qroutput.util.CreateResInfoWb;
import com.jfinal.core.Controller;
import org.apache.commons.codec.binary.Base64;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

//资源信息输出
public class QROutputController extends Controller {
    private Logger logger = LoggerFactory.getLogger(ExamineController.class);
    public HSSFWorkbook outputWb1() throws IOException {
        String fileName = "List";
        HttpServletResponse response = getResponse();
        HttpServletRequest request = getRequest();
        response.setHeader("Connection", "close");
        response.setHeader("Content-Type", "application/vnd.ms-excel;charset=UTF-8");
        String filename = System.currentTimeMillis() + fileName+".xls";
        filename = encodeFileName(request, filename);
        response.setHeader("Content-Disposition", "attachment;filename=" + filename);
        OutputStream out = null;
        out = response.getOutputStream();

        HSSFWorkbook wb1 = null;

        QrDao qd = new QrDao();
        ArrayList<ResourceInfo> resourceinfos = qd.getResourceInfoList();
        ArrayList<Scheme> schemes = new ArrayList<Scheme>();
        Scheme scheme = new Scheme("版本名","册名","章名","节名");
        schemes.add(scheme);
        ResourceInfo user1 = new ResourceInfo("序号","学段名","学科名",schemes,"分类名称","资源名","缩略图ID+扩展名","压缩文件ID+扩展名","http全路径","二维码文件ID+扩展名","创建时间","更新时间");

        resourceinfos.add(0,user1);
        CreateResInfoWb criw = new CreateResInfoWb();
        wb1 = criw.getWb(resourceinfos);
        return wb1;
//        wb1.write(out);
//        out.close();
//        out.flush();
    }

    public String encodeFileName(HttpServletRequest request, String fileName) throws UnsupportedEncodingException {
        String agent = request.getHeader("USER-AGENT");

        if (null != agent && -1 != agent.indexOf("MSIE")) {
            return URLEncoder.encode(fileName, "UTF-8");
        } else if (null != agent && -1 != agent.indexOf("Mozilla")) {
            return "=?UTF-8?B?"+ (new String(Base64.encodeBase64(fileName.getBytes("UTF-8")))) + "?=";
        } else {
            return fileName;
        }
    }

}
