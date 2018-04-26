package com.dsideal.space.qroutput.entity;

import java.util.ArrayList;

public class ResourceInfo {
    private String id;
//    private String stage_id;
    private String stage_name;
//    private String subject_id;
    private String subject_name;
    private ArrayList<Scheme> scheme_list;
//    private String category_id;
    private String category_name;
    private String name;
    private String thumb_id;
    private String zip_file_id;
//    private String zip_flag;
//    private String zip_status;
    private String url;
    private String qr_code;
    private String create_time;
    private String update_ts;

    public ResourceInfo(String id, String stage_name, String subject_name, ArrayList<Scheme> scheme_list, String category_name, String name, String thumb_id, String zip_file_id, String url, String qr_code, String create_time, String update_ts) {
        this.id = id;
        this.stage_name = stage_name;
        this.subject_name = subject_name;
        this.scheme_list = scheme_list;
        this.category_name = category_name;
        this.name = name;
        this.thumb_id = thumb_id;
        this.zip_file_id = zip_file_id;
        this.url = url;
        this.qr_code = qr_code;
        this.create_time = create_time;
        this.update_ts = update_ts;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getStage_name() {
        return stage_name;
    }

    public void setStage_name(String stage_name) {
        this.stage_name = stage_name;
    }

    public String getSubject_name() {
        return subject_name;
    }

    public void setSubject_name(String subject_name) {
        this.subject_name = subject_name;
    }

    public ArrayList<Scheme> getScheme_list() {
        return scheme_list;
    }

    public void setScheme_list(ArrayList<Scheme> scheme_list) {
        this.scheme_list = scheme_list;
    }

    public String getCategory_name() {
        return category_name;
    }

    public void setCategory_name(String category_name) {
        this.category_name = category_name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getThumb_id() {
        return thumb_id;
    }

    public void setThumb_id(String thumb_id) {
        this.thumb_id = thumb_id;
    }

    public String getZip_file_id() {
        return zip_file_id;
    }

    public void setZip_file_id(String zip_file_id) {
        this.zip_file_id = zip_file_id;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getQr_code() {
        return qr_code;
    }

    public void setQr_code(String qr_code) {
        this.qr_code = qr_code;
    }

    public String getCreate_time() {
        return create_time;
    }

    public void setCreate_time(String create_time) {
        this.create_time = create_time;
    }

    public String getUpdate_ts() {
        return update_ts;
    }

    public void setUpdate_ts(String update_ts) {
        this.update_ts = update_ts;
    }
}
