package com.dsideal.space.qroutput.util;


import com.dsideal.space.qroutput.entity.ResourceInfo;
import com.dsideal.space.qroutput.entity.Scheme;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.util.CellRangeAddress;

import java.util.ArrayList;

public class CreateResInfoWb {
    public HSSFWorkbook getWb(ArrayList<ResourceInfo> userlist) {
        HSSFWorkbook wb = new HSSFWorkbook();//创建
        HSSFSheet sheet = wb.createSheet("资源表");//命名
        HSSFCellStyle style = wb.createCellStyle();//声明样式变量
        style.setAlignment(HSSFCellStyle.ALIGN_CENTER);//水平居中
        style.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);//垂直居中
        //创建row
        ArrayList<Row> rowlist = createAllRows(userlist, sheet);
//        headTitle = title.getHeadTitle();
//		循环创建格子，写数据
        for (int i = 0; i < 15; i++) {
//		for(int i =0;i<11;i++){
            int index = 1;
            for (int j = 0; j < userlist.size(); j++) {
                ResourceInfo user = userlist.get(j);//获取当前行对象
                ArrayList<String> obj1 = Obj1(user);//把行对象里的属性转为List
                int size = user.getScheme_list().size();//获取格子高度
                //画格子
                if ((i >= 0 && i < 3) || (i >= 7 && i < 15)) {
                    CellRangeAddress cra = new CellRangeAddress(index - 1, index + size - 2, i, i);//合并单元格
                    sheet.addMergedRegion(cra);
                    sheet.autoSizeColumn(i, true);//自动适应宽度。

                }
                String str = obj1.get(i);
                //写数据
                //写每个对象的第一行数据
                Cell cell = rowlist.get(index - 1).createCell(i);
                cell.setCellStyle(style);//添加剧中样式
                cell.setCellValue(str); //写入格子
                //写每个对象其他行数据
                if (i >= 3 && i < 7) {
                    int m = 1;
                    for (int k = index; k < index + size - 1; k++) {
                        ArrayList<String> obj2 = Obj2(user.getScheme_list().get(m));
                        m++;
                        String str1 = obj2.get(i - 3);
                        Cell cell1 = rowlist.get(k).createCell(i);
                        cell1.setCellStyle(style);//添加居中样式
                        cell1.setCellValue(str1);
                    }
                    sheet.autoSizeColumn(i, true);//自动适应宽度。

                }
                index = index + size;
            }
            sheet.autoSizeColumn(i, true);//自动适应宽度。

        }
        for (int auto = 0; auto < 15; auto++) {
            sheet.autoSizeColumn(auto, true);//自动适应宽度。
        }
//        sheet.setColumnWidth(0, 8000);
        return wb;

    }

    //创捷所有的Row
    private ArrayList<Row> createAllRows(ArrayList<ResourceInfo> userlist, HSSFSheet sheet) {
        int sum = 0;
        ArrayList<Row> rowlist = new ArrayList<>();
        for (int i = 0; i < userlist.size(); i++) {
            sum = sum + userlist.get(i).getScheme_list().size();
        }
        for (int i = 0; i < sum; i++) {
            Row row = sheet.createRow(i);
            rowlist.add(row);
        }
        return rowlist;
    }

    //对象的属性转为ArrayList
    private ArrayList<String> Obj1(ResourceInfo userx) {
        ArrayList<String> objx = new ArrayList<>();
        ArrayList<String> obj2 = Obj2(userx.getScheme_list().get(0));
        objx.add(userx.getId());
//        objx.add(userx.getStage_id());
        objx.add(userx.getStage_name());
//        objx.add(userx.getSubject_id());
        objx.add(userx.getSubject_name());
        objx.add(String.valueOf(obj2.get(0)));
        objx.add(String.valueOf(obj2.get(1)));
        objx.add(String.valueOf(obj2.get(2)));
        objx.add(String.valueOf(obj2.get(3)));
//        objx.add(String.valueOf(obj2.get(4)));
//        objx.add(String.valueOf(obj2.get(5)));
//        objx.add(String.valueOf(obj2.get(6)));
//        objx.add(String.valueOf(obj2.get(7)));
//        objx.add(userx.getCategory_id());
        objx.add(userx.getCategory_name());
        objx.add(userx.getName());
        objx.add(userx.getThumb_id());
        objx.add(userx.getZip_file_id());
//        objx.add(userx.getZip_flag());
//        objx.add(userx.getZip_status());
        objx.add(userx.getUrl());
        objx.add(userx.getQr_code());
        objx.add(userx.getCreate_time());
        objx.add(userx.getUpdate_ts());
        return objx;
    }

    private ArrayList<String> Obj2(Scheme bt) {
        ArrayList<String> objx = new ArrayList<>();
//        objx.add(String.valueOf(bt.getVolume_id()));
//        objx.add(String.valueOf(bt.getScheme_id()));
//        objx.add(String.valueOf(bt.getChapter_id()));
//        objx.add(String.valueOf(bt.getSection_id()));
        objx.add(String.valueOf(bt.getScheme_name()));
        objx.add(String.valueOf(bt.getVolume_name()));
        objx.add(String.valueOf(bt.getChapter_name()));
        objx.add(String.valueOf(bt.getSection_name()));
        return objx;
    }
}
