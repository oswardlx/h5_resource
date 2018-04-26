package com.dsideal.space.qroutput.entity;

public class Scheme {
//    private String scheme_id;
//    private String volume_id;
//    private String chapter_id;
//    private String section_id;

    private String scheme_name;
    private String volume_name;
    private String chapter_name;
    private String section_name;

    public Scheme(String scheme_name, String volume_name, String chapter_name, String section_name) {
        this.scheme_name = scheme_name;
        this.volume_name = volume_name;
        this.chapter_name = chapter_name;
        this.section_name = section_name;
    }

    public String getScheme_name() {
        return scheme_name;
    }

    public void setScheme_name(String scheme_name) {
        this.scheme_name = scheme_name;
    }

    public String getVolume_name() {
        return volume_name;
    }

    public void setVolume_name(String volume_name) {
        this.volume_name = volume_name;
    }

    public String getChapter_name() {
        return chapter_name;
    }

    public void setChapter_name(String chapter_name) {
        this.chapter_name = chapter_name;
    }

    public String getSection_name() {
        return section_name;
    }

    public void setSection_name(String section_name) {
        this.section_name = section_name;
    }
}
