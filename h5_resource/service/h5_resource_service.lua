--
-- Created by IntelliJ IDEA.
-- User: 91946
-- Date: 2017/12/11
-- Time: 14:40
-- To change this template use File | Settings | File Templates.
--
local baseService = require("social.service.CommonBaseService")
local dao = require("space.h5_resource.dao.h5_resource_dao")
local TableUtil = require("social.common.table")
local catalogueSrv = require "ybk.prepareCourse.service.CatalogueSrv"
local _util = require "new_base.util"
local cjson = require "cjson"
local _SchemeSrv = require "base.scheme.service.SchemeSrv";
local prefix = ngx.config.prefix()
local filename = os.date("os%Y%m%d", os.time())
local filepath = prefix .. "logs/space/"
local mylog = string.format(filepath .. "%s.log", filename)
local log = require("social.common.log4j"):new(mylog)
local _PersonInfo = require("space.services.PersonAndOrgBaseInfoService")
local _M = {}


function _M.addExaminaPerson(param)
    baseService:checkParamIsNull({
        person_id = param.person_id,
        identity_id = param.identity_id,
        level = param.level,
        person_name = param.person_name,
        org_id = param.org_id,
        org_type = param.org_type,
        dept_id = param.dept_id,
        office_id = param.office_id
    });
    local result, id
    local func = function()
        local result = dao.findExaminePersonById(param.person_id, param.identity_id)
        log:debug(result)
        result, id = dao.addExaminaPerson(param);
    end
    local status = dao.txFunction(func)
    return status, id
end

function _M.addClass(param)
    local result, id = dao.addClass(param)
    return result, id
end

function _M.removeClassById(id)
    local resultinfo
    local func = function()
        local result = dao.getresourceByCategory(id)
        --        log:debug(result)
        --        if result ==false then
        --            resultinfo = "该类还存在资源"
        --            error("still remain resource")
        --        end

        local result2 = dao.removeClassById(id)
        --        if result2 ==false then
        --            resultinfo = "操作有误"
        --            error("fault operation")
        --        end
    end
    local status = dao.txFunction(func)
    return status, resultinfo
end

function _M.addResource(param, schemeList)
    log:debug(#schemeList)
    log:debug(121212121212121212122)
    local result, id
    local func = function()
        result, id = dao.addResource(param)
        log:debug(schemeList)
        for i = 1, #schemeList do
            log:debug(111111111111111111111)

            dao.setResourceScheme({
                h5_resource_id = id,
                scheme_id = schemeList[i]['scheme_id'],
                volume_id = schemeList[i]['volume_id'],
                chapter_id = schemeList[i]["chapter_id"],
                section_id = schemeList[i]["section_id"]
            })
        end
    end
    local status = dao.txFunction(func)
    return status
end

function _M.updateResource(param, schemeList)
    log:debug(param)
    local func = function()
        dao.deleteScheme(param.id)
        dao.updateResource(param)
        log:debug(schemeList)
        for i = 1, #schemeList do
            dao.setResourceScheme({
                h5_resource_id = param.id,
                chapter_id = schemeList[i]['chapter_id'],
                section_id = schemeList[i]['section_id'],
                scheme_id = schemeList[i]['scheme_id'],
                volume_id = schemeList[i]['volume_id'],
            })
        end
    end
    local status = dao.txFunction(func)
    return status
    --    local result,id = dao.updateResource(param,schemeList)
    --    return result ,id
end

function _M.setResourceScheme(param)
    local result, id = dao.setResourceScheme(param)
    return result, id
end

function _M.getClassById(id)
    local result, id = dao.getClassById(id)
    return result, id
end

function _M.getClassBySeq(sequence)
    local result, id = dao.getClassBySeq(sequence)
    return result, id
end

function _M.getClasses(subject_id, sort_type)
    local result = dao.getClasses(subject_id, sort_type)
    return result
end

function _M.removeResourceById(id)
    local result = dao.removeResourceById(id)
    return result
end

function _M.removeResourceByCategoryId(id)
    local result = dao.removeResourceByCategoryId(id)
    return result
end


function _M.removeClassAndResources(id)
    local func = function()
        dao.removeClassById(id)
        dao.removeResourceByCategoryId(id);
    end
    local status = dao.txFunction(func)
    return status
end

function _M.getResourcesByKinds(param, name, page_size, page_num, start_time, end_time, scheme_id, volume_id, chapter_id, section_id)
    local resultInfo, totalpage, total_row
    local func = function()
        resultInfo, totalpage, total_row = dao.getResourcesByKinds(param, name, page_size, page_num, start_time, end_time, scheme_id, volume_id, chapter_id, section_id)
        if resultInfo then
            for k = 1, #resultInfo do
                if resultInfo[k] and resultInfo[k]['category_id'] then
                    resultInfo[k]["category_name"] = dao.getClassById(resultInfo[k]['category_id'])[1]['name']
                end
            end
        end
    end
    local status = dao.txFunction(func)
    if status == false then
        return false
    end
    log:debug(totalpage)
    return resultInfo, totalpage, total_row
end

function _M.updateClass(param)
    local result = dao.updateClass(param)
    return result
end

function _M.getRecord(param)
    local result = dao.getRecord(param)
    return result
end

function _M.writeRecord(param)
    local result = dao.writeRecord(param)
    return result
end

function _M.getResourceById(id)
    local result = {}
    local schemeList = {}
    result = dao.getResourceById(id)
    if not result or result == false then
        return false
    end
    schemeList = dao.getSchemeByh5Id(id);
    if not schemeList or schemeList == false then
        return false
    end
    result[1]["schemeList"] = schemeList
    return result[1]
end

function _M.getCounts()
    local pc_count, mob_count, reg_count = dao.getCounts()
    return pc_count, mob_count, reg_count
end

function _M.updateNames(id, stage_name, subject_name)
    local result = dao.updateNames(id, stage_name, subject_name)
    return result
end

function _M.getVisitResourceCount(param, page_num, page_size)
    local result, totalpage, total_row = dao.getVisitResourceCount(param, page_num, page_size)
    if result then
        for k = 1, #result do
            if result[k] and result[k]['category_id'] then
                result[k]["category_name"] = dao.getClassById(result[k]['category_id'])[1]['name']
            end
        end
    end
    local schemeList = {}
    for i = 1, #result do
        schemeList = dao.getSchemeByh5Id(result[i]["Id"]);
        if not schemeList or schemeList == false then
            return false
        end
        result[i]["schemeList"] = schemeList
    end
    for i = 1, #result do
        result[i].pc_count, result[i].mob_count = dao.getResourceVisitCount(result[i].Id);
        log:debug(result[i].mob_count)
        log:debug(result[i])
    end
    return result, totalpage, total_row
end

function _M.getSchemeInfoBySubject(subject_id)
    local status, result = _SchemeSrv: getStandardSchemeBySubject(subject_id)
    log:debug(1111)
    log:debug(result)
    local result2 = dao.getSchemeInfoBySubjectlx(subject_id)
    log:debug(result2)
    local result3={}
    local index =1
    for i=1,#result do
        for j = 1,#result2 do
            if result[i]["version_id"]==result2[j]["scheme_id"] then
                result3[index] = {}
                result3[index]["version_id"]=result[i]["version_id"]
                result3[index]["version_name"]=result[i]["version_name"]
                index = index +1
            end
        end
    end
    return result3
end

function _M.getVolumeInfoByScheme(scheme_id)
    local volumeArray, schemeCache = catalogueSrv:getVolumeByScheme(scheme_id)
    local result2 = dao.getVolumeInfoBySchemelx(scheme_id)
    log:debug(11111)
    log:debug(volumeArray)
    log:debug(122222)
    log:debug(result2)
    local result3={}
    local index =1
    for i=1,#volumeArray do
        for j = 1,#result2 do
            if volumeArray[i]["structure_id"]==""..result2[j]["volume_id"] then
                result3[index]=volumeArray[i]
                index =index+1
            end
        end
    end
    return result3,schemeCache

end

function _M.getChapterInfoBySchemeAndVolume(result,scheme_id,volume_id)
    log:debug("11111111111111")
    log:debug(result)
    local result2 = dao.getChapterInfoBySchemeAndVolume(scheme_id,volume_id)
    log:debug(2222222222)
    log:debug(result2)
    local result3={}
    local index =1
    for i=1,#result do
        for j = 1,#result2 do
            if result[i]["id"]==""..result2[j]["chapter_id"] then
                result3[index]=result[i]
                index= index+1
            end
        end
    end
    log:debug(result3)
    return result3
end
return baseService:inherit(_M):init()