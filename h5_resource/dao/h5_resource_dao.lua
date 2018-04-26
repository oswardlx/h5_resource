--
-- Created by IntelliJ IDEA.
-- User: 91946
-- Date: 2017/12/11
-- Time: 14:40
-- To change this template use File | Settings | File Templates.
--

local baseDao = require("social.dao.CommonBaseDao")
local DBUtil = require "social.common.mysqlutil";
local prefix = ngx.config.prefix()
local filename = os.date("os%Y%m%d", os.time())
local filepath = prefix .. "logs/space/"
local mylog = string.format(filepath .. "%s.log", filename)
local log = require("social.common.log4j"):new(mylog)
local TableUtil = require("social.common.table")
local quote = ngx.quote_sql_str
local ssdbutil = require "social.common.ssdbutil"

local _M = {}

--计算分页
local function computePage(count, page_size, page_num)
    local _page_num = page_num;
    local Page = math.floor((count + page_size - 1) / page_size)
    if Page > 0 and page_num > Page then
        page_num = Page
    end
    local offset = page_size * page_num - page_size
    if _page_num > Page then
        return Page, 10000000
    end
    return Page, offset
end

--查询条件字符串化
function _M.sqlsfunc(param)
    local column = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "-1" then
            table.insert(column, key .. "=" .. quote(var))
        end
    end
    local str = "and %s "
    local sql = str:format(table.concat(column, " and "))
    return sql
end

--通用insert语句
function _M.insertfunc(tableName, param)
    local column = {}
    local values = {}
    log:debug(param)
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key)
            table.insert(values, quote(var))
        end
    end
    local templet = "INSERT INTO `%s` (`%s`) VALUES (%s)"
    local sql = templet:format(tableName, table.concat(column, "`,`"), table.concat(values, ","))
    log:debug(sql);
    local db = DBUtil:getDb();
    local result,err = db:query(sql)
    log:debug(err)
    log:debug(result)
    if result and result.insert_id > 0 then
        return true, result.insert_id
    end
    if not result then
        error('fail.')
    end
end

--通用update语句
function _M.updatefunc(tableName, param)
    local column = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key .. "=" .. quote(var))
        end
    end
    local templet = "UPDATE %s set %s where id =  %s "
    local sql = templet:format(tableName, table.concat(column, ","), param.id)
    log:debug(param)
    log:debug(sql)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows >= 0 then
        return true, param.id
    end
    --    error("updateInfo failed")
    return false
end

--select
function _M.querySql(sql)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result then
        return false
    end
    return result
end

function _M.addClass(param)
    return _M.insertfunc('T_SOCIAL_H5_RESOURCE_CATEGORY', param)
end

function _M.removeClassById(id)
    local sql = "DELETE FROM T_SOCIAL_H5_RESOURCE_CATEGORY where id = " .. id
    log:debug(sql)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows > 0 then
        return true
    end
    error("removeClassById failed")
    --    return false
end

function _M.getresourceByCategory(id)
    local sql = "select COUNT(DISTINCT id) as Row FROM T_SOCIAL_H5_RESOURCE where category_id = " .. id
    log:debug(sql)

    local db = DBUtil:getDb();
    local result = db:query(sql)
    log:debug(result[1]['Row'])
    if result[1]['Row'] == '0' then
        return true
    end
    error("still remain resource")
end

function _M.addResource(param)
    return _M.insertfunc('T_SOCIAL_H5_RESOURCE', param)
end

function _M.updateResource(param)
    log:debug(param)
    return _M.updatefunc('T_SOCIAL_H5_RESOURCE', param)
end

function _M.setResourceScheme(param)
    log:debug(param)
    return _M.insertfunc('t_social_h5_resource_scheme', param)
end

function _M.getClassById(id)
    local sql = "SELECT * FROM T_SOCIAL_H5_RESOURCE_CATEGORY where id = " .. id
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result then
        error('get fail.')
    end
    return result
end

function _M.getClassBySeq(sequence)
    local sql = "SELECT * FROM T_SOCIAL_H5_RESOURCE_CATEGORY where sequence = " .. sequence
    return _M.querySql(sql)
end

function _M.getClasses(subject_id, sort_type)
    local addsql1 = ""
    if sort_type == 1 then
        addsql1 = ""
    elseif sort_type == 0 then
        addsql1 = "sequence desc"
    elseif sort_type == 2 then
        addsql1 = " create_time "
    end
    local sql = "SELECT * FROM T_SOCIAL_H5_RESOURCE_CATEGORY where subject_id = " .. subject_id .. " ORDER BY " .. addsql1
    log:debug(sql)
    return _M.querySql(sql)
end

function _M.removeResourceById(id)
    local sql = "DELETE FROM T_SOCIAL_H5_RESOURCE WHERE id = " .. id
    log:debug(sql)
    local db = DBUtil:getDb()
    local result = db:query(sql)
    log:debug(result)
    if not result or result.affected_rows <= 0 then
        error("DELETE T_SOCIAL_H5_RESOURCE fail.")
    end
    return true
end

function _M.removeResourceByCategoryId(id)
    local sql = "DELETE FROM T_SOCIAL_H5_RESOURCE WHERE category_id = " .. id
    log:debug(sql)
    local db = DBUtil:getDb()
    local result = db:query(sql)
    log:debug(result)
    if not result or result.affected_rows <= 0 then
        error("DELETE T_SOCIAL_H5_RESOURCE fail.")
    end
    return true
end

function _M.updateNames(id, stage_name, subject_name)
    local param = {}
    param.stage_name = stage_name
    param.id = id
    param.subject_name = subject_name
    return _M.updatefunc("T_SOCIAL_H5_RESOURCE", param)
end

local function getResourcesByKindsCount(addsql1, addsql2, addsql3, addsql4, addsql5, addsql6, addsql7)
    local sql = "select COUNT(DISTINCT id) as Row from T_SOCIAL_H5_RESOURCE ,T_SOCIAL_H5_RESOURCE_SCHEME s where 1=1 and id =s.h5_resource_id " .. addsql3 .. addsql2 .. addsql1 .. addsql4 .. addsql5 .. addsql6 .. addsql7
    log:debug(sql)
    local result = _M.querySql(sql)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function getResourcesByKindsList(addsql3, addsql2, addsql1, page_size, offset, addsql4, addsql5, addsql6, addsql7)
    local sql = "SELECT * FROM T_SOCIAL_H5_RESOURCE,T_SOCIAL_H5_RESOURCE_SCHEME s where 1=1 and id =s.h5_resource_id " .. addsql1 .. addsql2 .. addsql3 .. addsql4 .. addsql5 .. addsql6 .. addsql7 .. " GROUP BY id order by create_time DESC limit " .. offset .. "," .. page_size .. ";"
    log:debug(sql)
    local result = _M.querySql(sql)
    return result
end


function _M.getResourcesByKinds(param, name, page_size, page_num, start_time, end_time, scheme_id, volume_id, chapter_id, section_id)
    local addsql1 = _M.sqlsfunc(param)
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 = ""
    local addsql5 = ""
    local addsql6 = ""
    local addsql7 = ""
    if scheme_id and scheme_id ~= -1 and scheme_id ~= "" then
        addsql4 = " and s.scheme_id=" .. scheme_id
    end
    if volume_id and volume_id ~= -1 and volume_id ~= "" then
        addsql5 = " and s.volume_id=" .. volume_id
    end
    if chapter_id and chapter_id ~= -1 and chapter_id ~= "" then
        addsql6 = " and s.chapter_id=" .. chapter_id
    end
    if section_id and section_id ~= -1 and section_id ~= "" then
        addsql7 = " and s.section_id=" .. section_id
    end

    if name ~= "" then
        addsql2 = " and name like '%" .. name .. "%' "
    end
    if start_time ~= "-1" and end_time ~= "-1" then
        start_time = start_time .. " 00:00:00"
        end_time = end_time .. " 23:59:59"
        addsql3 = " and create_time between '" .. start_time .. "' and '" .. end_time .. "'"
    end
    local count = getResourcesByKindsCount(addsql1, addsql2, addsql3, addsql4, addsql5, addsql6, addsql7);
    local list = {}
    local _page = 0
    local offset


    if (count and tonumber(count) > 0) or count == "0" then
        _page, offset = computePage(count, page_size, page_num);
        if offset < 0 then
            offset = 0
        end
        list = getResourcesByKindsList(addsql3, addsql2, addsql1, page_size, offset, addsql4, addsql5, addsql6, addsql7);
    end
    log:debug(11231232131231231232)
    log:debug(count)
    log:debug(_page)
    log:debug(11231232131231231232)
    return list, _page, count
end


function _M.updateClass(param)
    return _M.updatefunc('t_social_h5_resource_category', param)
end

function _M.getRecord(param)
    local addsql1 = ""
    local addsql2 = ""
    local addsql3 = ""
    if param.start_time == "-1" or param.end_time == "-1" then
        addsql3 = ""
    else
        param.start_time = param.start_time .. " 00:00:00"
        param.end_time = param.end_time .. " 23:59:59"
        addsql3 = " and create_time between '" .. param.start_time .. "' and '" .. param.end_time .. "'"
    end
    if param.client_type ~= -1 then
        addsql1 = " and CLIENT_TYPE_ID = " .. param.client_type
    end
    if param.h5_resource_id ~= -1 then
        addsql2 = " and h5_resource_id= " .. param.h5_resource_id
    end
    local sql = " Select count(DISTINCT id) as row FROM t_social_h5_resource_record where 1=1 " .. addsql1 .. addsql2 .. addsql3
    log:debug(sql)
    local result = _M.querySql(sql)
    if result and result[1] then
        return result[1]['row']
    end
    return 0;
end

function _M.writeRecord(param)
    return _M.insertfunc("t_social_h5_resource_record", param)
end

function _M.deleteScheme(h5_resource_id)
    local sql = " DELETE FROM t_social_h5_resource_scheme where h5_resource_id = " .. h5_resource_id
    local db = DBUtil:getDb()
    local result = db:query(sql)
    if not result or result.affected_rows <= 0 then
        error("DELETE T_SOCIAL_H5_scheme fail.")
    end
    return true
end

function _M.getResourceById(id)
    local sql = "SELECT * from T_SOCIAL_H5_RESOURCE where id = " .. id
    log:debug(sql)
    return _M.querySql(sql)
end

function _M.getSchemeByh5Id(id)
    local sql = "SElect * From t_social_h5_resource_scheme where h5_resource_id = " .. id
    local ssdb = ssdbutil:getDb()
    local result = _M.querySql(sql)
    log:debug(result)
    for i = 1, #result do
        local schemeName = ""
        local schemeId = result[i]["scheme_id"]
        log:debug(schemeId)
        local status = pcall(function()
            local result = ssdb:multi_hget("t_resource_scheme_" .. schemeId, "scheme_name");
            log:debug(result)
            schemeName = result[2]
            log:debug("schemeName:" .. schemeName)
        end)
        result[i]["scheme_name"] = schemeName

        local volumeId = result[i]["volume_id"]
        local chapter_id = result[i]["chapter_id"]
        local section_id = result[i]["section_id"]
        local _CatalogueSrv = require "base.structure.services.StructureService";
        local strucName = ""
        local section_name = ""
        local chapter_name = ""
        local status = pcall(function()
            local strucInfo = _CatalogueSrv:getStrucInfo(volumeId)
            strucName = strucInfo["structure_name"]
        end)
        local status = pcall(function()
            local strucInfo2 = _CatalogueSrv:getStrucInfo(chapter_id)
            chapter_name = strucInfo2["structure_name"]
        end)
        local status = pcall(function()
            local strucInfo3 = _CatalogueSrv:getStrucInfo(section_id)
            section_name = strucInfo3["structure_name"]
        end)
        result[i]["chapter_name"] = chapter_name
        result[i]["section_name"] = section_name
        result[i]["volume_name"] = strucName
    end
    log:debug(result)
    return result
end

--function _M.getRegisterCount()
--    local sql = "Select Count(person_id) reg_count from t_base_person where register_flag = 10 and b_use =1"
--    local result =_M.querySql(sql)
--    if result and result[1] then
--        return result[1]['reg_count']
--    end
--    return 0;
--end

function _M.getCounts()
    local sql = "Select a.count pc_count,b.count mob_count,c.count reg_count from (Select Count(id) count From t_social_h5_resource_record where CLIENT_TYPE_ID = 1) a ,(Select Count(id) count From t_social_h5_resource_record where CLIENT_TYPE_ID = 2) b, (Select Count(person_id) count from t_base_person where register_flag = 10 and b_use =1) c"
    log:debug(sql)
    local result = _M.querySql(sql)
    if result and result[1] then
        --        ngx.say(result[1]['pc_count'].."   "..result[1]['mob_count'].."      "..result[1]['reg_count'])
        return result[1]['pc_count'], result[1]['mob_count'], result[1]['reg_count']
    end
    return 0;
end

local function getVisitResourceCountCount(addsql1)
    local sql = "select COUNT(DISTINCT id) as Row from T_SOCIAL_H5_RESOURCE where 1=1 " .. addsql1 .. " "
    log:debug(sql)
    local result = _M.querySql(sql)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function getVisitResourceCountList(addsql1, page_size, offset)
    local sql = "SELECT * FROM T_SOCIAL_H5_RESOURCE where 1=1  " .. addsql1 .. " order by create_time DESC limit " .. offset .. "," .. page_size .. ";"
    log:debug(sql)
    local result = _M.querySql(sql)
    return result
end

function _M.getVisitResourceCount(param, page_num, page_size)
    local addsql1 = _M.sqlsfunc(param)
    local count = getVisitResourceCountCount(addsql1);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        list = getVisitResourceCountList(addsql1, page_size, offset);
    end
    return list, _page, count
end

function _M.getResourceVisitCount(id)
    local sql = "select a.pc_count pc_count,b.mob_count mob_count from (Select Count(id) pc_count from t_social_h5_resource_record where h5_resource_id = " .. id .. " and CLIENT_TYPE_ID = 1) a,(Select Count(id) mob_count From t_social_h5_resource_record where h5_resource_id = " .. id .. " and CLIENT_TYPE_ID=2) b"
    log:debug(sql)
    local result = _M.querySql(sql)
    if result and result[1] then
        return result[1]['pc_count'], result[1]["mob_count"]
    end
    return 0;
end

--根据subjectid获取schemeId ，和schemename
function _M.getSchemeInfoBySubjectlx(subject_id)
    local sql ="Select Distinct(s.scheme_id) from t_social_h5_resource_scheme s ,t_social_h5_resource r where s.h5_resource_id = r.Id and r.subject_id = "..subject_id.." and r.zip_status = 1;"
    local ssdb = ssdbutil:getDb()
    local result = _M.querySql(sql)
    return result;
end

function _M.getVolumeInfoBySchemelx(scheme_id)
    local sql ="Select DISTINCT(s.volume_id) from t_social_h5_resource_scheme s , t_social_h5_resource r  where s.scheme_id = "..scheme_id.." and s.h5_resource_id = r.Id  and r.zip_status = 1;"
    local ssdb = ssdbutil:getDb()
    local result = _M.querySql(sql)
    return result;
end

function _M.getChapterInfoBySchemeAndVolume(scheme_id,volume_id)
    local sql = "Select DISTINCT(s.chapter_id) from t_social_h5_resource_scheme s ,t_social_h5_resource r where s.scheme_id = "..scheme_id.." and s.volume_id ="..volume_id.." and s.h5_resource_id = r.Id and  r.zip_status = 1;"
    local ssdb = ssdbutil:getDb()
    local result = _M.querySql(sql)
    return result;
end
return baseDao:inherit(_M):init()
