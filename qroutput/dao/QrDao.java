package com.dsideal.space.qroutput.dao;

import com.dsideal.space.qroutput.entity.ResourceInfo;
import com.dsideal.space.qroutput.entity.Scheme;
import com.dsideal.util.redis.JedisUtils;
import com.dsideal.util.ssdb.SSDBUtils;
import com.jfinal.plugin.activerecord.Db;
import com.jfinal.plugin.activerecord.Record;

import java.text.SimpleDateFormat;
import java.util.*;

public class QrDao {

    //    获取资源列表
    public ArrayList<ResourceInfo> getResourceInfoList() {
        String sql = "select * From t_social_h5_resource";
        List<Record> userList = Db.find(sql);
        ArrayList<ResourceInfo> ris = new ArrayList<ResourceInfo>();
        for (Record record : userList) {
            String id = String.valueOf(record.getInt("id"));
            ArrayList<Scheme> schemes = getSchemeList(id);
            String stage_id = formatNull(String.valueOf(record.getInt("stage_id")));
            String subject_id = formatNull(String.valueOf(record.getInt("subject_id")));
            String category_id = formatNull(String.valueOf(record.getInt("category_id")));
            String name = formatNull(String.valueOf((record.getStr("name"))));
            String thumb_id = formatNull(String.valueOf(record.getStr("thumb_id")));
            String zip_file_id = formatNull(String.valueOf(record.getStr("zip_file_id")));
            String zip_flag = formatNull(String.valueOf(record.getInt("zip_flag")));
            String zip_status = formatNull(String.valueOf(record.getInt("zip_status")));
            String url = formatNull(String.valueOf(record.getStr("url")));
            String qu_code = formatNull(String.valueOf(record.getStr("qr_code")));
            Date datet = record.getDate("create_time");
            String stage_name = formatNull(String.valueOf(record.getStr("stage_name")));
            String subject_name = formatNull(String.valueOf(record.getStr("subject_name")));

            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String create_time = "";
            if (datet != null) {
                create_time = simpleDateFormat.format(datet);
            }
            System.out.println("date:" + datet);
            Date update_tst = record.getDate("update_ts");
            String update_ts = "";
            if (update_tst != null) {
                update_ts = simpleDateFormat.format(update_tst);
            }
            String category_name = getCategoryName(category_id);
            System.out.println("123123123123123");
            System.out.println(create_time + "    " + update_ts);
            System.out.println("123123123123123");

            ResourceInfo ri = new ResourceInfo(id, stage_name, subject_name, schemes, category_name, name, thumb_id, zip_file_id, url, qu_code, create_time, update_ts);
            ris.add(ri);
        }
        return ris;
    }

    public String getCategoryName(String id) {
        String sql = "select name From t_social_h5_resource_category where id = " + id;
        System.out.println(sql);

        List<Record> userList = Db.find(sql);
        String name = "";
        for (Record record : userList) {
            name = String.valueOf(record.getStr("name"));
        }
        return name;
    }

    public ArrayList<Scheme> getSchemeList(String id) {
        String sql = "SELECT scheme_id,volume_id,chapter_id,section_id From t_social_h5_resource_scheme where h5_resource_id= " + id;
        List<Record> userList = Db.find(sql);
        ArrayList<Scheme> schemes = new ArrayList<Scheme>();
        for (Record record : userList) {
            String scheme_id = String.valueOf(record.getInt("scheme_id"));
            String volume_id = String.valueOf(record.getInt("volume_id"));
            String chapter_id = String.valueOf(record.getInt("chapter_id"));
            String section_id = String.valueOf(record.getInt("section_id"));
            String scheme_name = "";
            String volume_name = "";
            String chapter_name = "";
            String section_name = "";

            try {
                Map schemeCache = SSDBUtils.multi_hget_map("t_resource_scheme_" + scheme_id, "scheme_name", "scheme_id");
                if (schemeCache.size() != 0) {
                    scheme_name = (String) schemeCache.get("scheme_name");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            Map strucCache = JedisUtils.hmgetMap("t_resource_structure_" + volume_id, "structure_name", "structure_id");
            if (strucCache.size() != 0) {
                volume_name = (String) strucCache.get("structure_name");
            }
            Map strucCache2 = JedisUtils.hmgetMap("t_resource_structure_" + chapter_id, "structure_name", "structure_id");
            if (strucCache2.size() != 0) {
                chapter_name = (String) strucCache2.get("structure_name");
            }
            Map strucCache3 = JedisUtils.hmgetMap("t_resource_structure_" + section_id, "structure_name", "structure_id");
            if (strucCache3.size() != 0) {
                section_name = (String) strucCache3.get("structure_name");
            }
//            System.out.println("osward129");
            System.out.println("osward863");
            System.out.println("osward164");
            System.out.println(section_id);
            scheme_id = formatNull(scheme_id);
            volume_id = formatNull(volume_id);
            chapter_id = formatNull(chapter_id);
            section_id = formatNull(section_id);
            System.out.println(section_id);
//            section_id = setNull(section_id);
//            System.out.println(section_id);
            System.out.println("osward164");

            Scheme scheme = new Scheme(scheme_name, volume_name, chapter_name, section_name);
            schemes.add(scheme);
        }
        return schemes;
    }

    public Map<String, String> getQrUrl() {
        String sql = "SELECT zip_file_id,qr_code FROM t_social_h5_resource ";
        List<Record> userList = Db.find(sql);
        Map<String, String> urlStr = new HashMap<>();
        for (Record record : userList) {
            String url = String.valueOf(record.getStr("zip_file_id"));
            String qr_code = String.valueOf(record.getStr("qr_code"));
            if (url == null || qr_code == null) {
                break;
            }
            String filename = url.substring(0, url.length() - 4) + ".png";
            urlStr.put(qr_code, filename);
        }
        return urlStr;
    }

    private String formatNull(String str1) {
        if (str1 == "0" || str1.equals(0) || str1.equals("0") || str1 == "null" || str1.equals(null) || str1.equals("null")) {
            return "";
        }
        return str1;
    }
}
