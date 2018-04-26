--
-- Created by IntelliJ IDEA.
-- User: 91946
-- Date: 2017/12/11
-- Time: 14:36
-- To change this template use File | Settings | File Templates.
--

local uri = ngx.var.uri
--local test1  = require("requiretest")
local web = require("social.router.router")
local request = require("social.common.request")
--local schemectl = require("base.scheme.controller.SchemeCtl")
local _SchemeSrv = require "base.scheme.service.SchemeSrv";
local catalogueSrv = require "ybk.prepareCourse.service.CatalogueSrv"
local _util = require "new_base.util"
local permission_context = ngx.var.path_uri --有权限的context.
local permission_no_context = ngx.var.path_uri_no_permission
local ssdb_dao = require("space.course_package.dao.CoursePackageSSDBDao")
local _PersonInfo = require("space.services.PersonAndOrgBaseInfoService")
local quote = ngx.quote_sql_str
local management_context = ngx.var.management_path_uri
local TableUtil = require("social.common.table")

local cjson = require "cjson"
local prefix = ngx.config.prefix()
local filename = os.date("os%Y%m%d", os.time())
local filepath = prefix .. "logs/space/"
local mylog = string.format(filepath .. "%s.log", filename)
local log = require("social.common.log4j"):new(mylog)
local service = require("space.h5_resource.service.h5_resource_service")
local TS = require "resty.TS"

--local function sqlsfunc(param)
--    local column = {}
--    for key, var in pairs(param) do
--        if param[key] and tostring(param[key]) ~= "-1" then
--            table.insert(column, key .. "=" .. quote(var))
--        end
--    end
--    local str ="and %s "
--    local sql = str:format(table.concat(column," and "))
--    return sql
--end
local function index()
    log:debug(111111111111111111111111111111111)
    local temp = { er = 1, erw = 'weqe', eweq = 345 }
    --    local result= sqlsfunc(temp)
    ngx.redirect("/dsideal_yy/html/space/H5Res/login/login.html")
end

--获取资源表请求参数
local function getResourceRequest()
    local category_id = request:getNumParam("category_id", true, true)
    local name = request:getStrParam("name", true, true)
    local stage_id = request:getNumParam("stage_id", true, true)
    local subject_id = request:getNumParam("subject_id", true, true)
    local thumb_id = request:getStrParam("thumb_id", true, true)
    local zip_flag = request:getNumParam("zip_flag", true, true)
    local zip_status = request:getNumParam("zip_status", true, true)
    local stage_name = request:getStrParam("stage_name", true, true)
    local subject_name = request:getStrParam("subject_name", true, true)
    local param = {
        category_id = category_id,
        name = name,
        stage_id = stage_id,
        subject_id = subject_id,
        thumb_id = thumb_id,
        zip_flag = zip_flag,
        zip_status = zip_status,
        stage_name = stage_name,
        subject_name = subject_name
    }
    return param
end

--获取分类表的请求参数
local function getClassRequest()
    local name = request:getStrParam("name", false, false)
    local sequence = request:getNumParam("sequence", false, false)
    local stage_id = request:getNumParam("stage_id", false, false)
    local subject_id = request:getNumParam("subject_id", false, false)
    local param = {
        name = name,
        sequence = sequence,
        stage_id = stage_id,
        subject_id = subject_id
    }
    return param
end

--获取更新请求
local function getClassRequestUpdate()
    local category_id = request:getNumParam("category_id", false, false)
    local name = request:getStrParam("name", false, false)
    local sequence = request:getNumParam("sequence", false, false)
    local stage_id = request:getNumParam("stage_id", false, false)
    local subject_id = request:getNumParam("subject_id", false, false)
    local stage_name = request:getStrParam("stage_name", false, false)
    local subject_name = request:getStrParam("subject_name", false, false)
    local thumb_id = request:getStrParam("thumb_id", false, false)
    local zip_status = request:getNumParam("zip_status", false, false)
    local zip_flag = request:getNumParam("zip_flag", false, false)
    local zip_file_id = request:getNumParam("zip_file_id", false, false)
    log:debug("subject_name:" .. subject_name)
    local param = {}
    if zip_file_id then
        param.zip_file_id = zip_file_id
    end
    if zip_status then
        param.zip_status = zip_status
    end
    if zip_flag then
        param.zip_flag = zip_flag
    end
    if thumb_id then
        param.thumb_id = thumb_id
    end

    if category_id then
        param.category_id = category_id
    end
    if name then
        param.name = name
    end
    if sequence then
        param.sequence = sequence
    end
    if stage_id then
        param.stage_id = stage_id
    end
    if subject_id then
        param.subject_id = subject_id
    end
    if stage_name then
        param.stage_name = stage_name
    end
    if subject_name then
        param.subject_name = subject_name
    end
    return param
end


--获取访问记录请求参数
local function getRecordRequest()
    local h5_resource_id = request:getNumParam("h5_resource_id", true, true)
    local client_type = request:getNumParam("client_type", true, true)
    local start_time = request:getStrParam("start_time", true, true)
    local end_time = request:getStrParam("end_time", true, true)

    local param = {
        h5_resource_id = h5_resource_id,
        client_type = client_type,
        start_time = start_time,
        end_time = end_time
    }
    return param
end

local function getSchemeRequest()
    local volume_id = request:getNumParam("volume_id", true, true)
    local h5_resource_id = request:getNumParam("h5_resource_id", true, true)
    local scheme_id = request:getNumParam("scheme_id", true, true)
    local param = {
        volume_id = volume_id,
        h5_resource_id = h5_resource_id,
        scheme_id = scheme_id
    }
    return param
end

--创建一个分类
local function addClass()
    local param = getClassRequest()
    local result, id = service.addClass(param);
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "创建失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--按照id删除一个分类
local function removeClassById()
    local id = request:getNumParam("id", true, true)
    local result, info = service.removeClassById(id)
    if not result or result == false then
        ngx.say(cjson.encode({ success = false, info = "删除失败，该类还有资源或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result }))
    return;
end




--添加一个资源
local function addResource()
    local param = getResourceRequest()
    local zip_file_id = request:getStrParam("zip_file_id", true, true)
    param.zip_file_id = zip_file_id
    local schemeList = request:getStrParam("schemeList", true, true)
    log:debug(schemeList)
    schemeList = cjson.decode(schemeList)
    log:debug(schemeList)
    --    local chapter = request:getStrParam("chapter",false,false)
    --    local section = request:getStrParam("section",false,false)
    --    if not chapter then
    --        param.chapter = -1
    --    end
    --    if not section then
    --        param.section=  -1
    --    end
    --    param.chapter = chapter
    --    param.section = section
    log:debug(TableUtil:length(schemeList))
    log:debug(type(schemeList))
    local result, id = service.addResource(param, schemeList)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "添加失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--更新一个资源
local function updateResource()
    local id = request:getNumParam("id", true, true)
    local param = getClassRequestUpdate()
    if next(param) == nil then
        ngx.say(cjson.encode({ success = false, info = "未填写需要跟新的数据，或操作有误" }))
        return;
    end
    param.id = id
    param.update_ts = os.date("%Y-%m-%d %H:%M:%S")
    local schemeList = request:getStrParam("schemeList", true, true)
    schemeList = cjson.decode(schemeList)
    local result, id = service.updateResource(param, schemeList)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "更新失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--更新学科名学段名
local function updateNames()
    local id = request:getNumParam("id", true, true)
    local stage_name = request:getStrParam("stage_name", true, true)
    local subject_name = request:getStrParam("subject_name", true, true)
    local result = service.updateNames(id, stage_name, subject_name)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "更新失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--设置资源版本关系
local function setResourceScheme()
    local param = getSchemeRequest()
    local result, id = service.setResourceScheme(param)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "设置失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--按照id获取资源分类信息
local function getClassById()
    local id = request:getNumParam("id", true, true)
    local result, id = service.getClassById(id)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "获取列表失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, create_time = result[1].create_time, id = result[1].id, sequence = result[1].sequence, subject_id = result[1].subject_id, name = result[1].name, stage_id = result[1].stage_id }))
    return;
end

--按照排序获取资源分类
local function getClassBySeq()
    local sequence = request:getNumParam("sequence", true, true)
    local result, id = service.getClassBySeq(sequence)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "获取列表失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, result = result, id = id }))
    return;
end

--获取所有分类
local function getClasses()
    local subject_id = request:getNumParam("subject_id", true, true)
    log:debug(subject_id)
    local sort_type = request:getNumParam("sort_type", false, false)
    if not sort_type then
        sort_type = 2
    end
    local result = service.getClasses(subject_id, sort_type)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "获取列表失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, resultList = result }))
    return;
end

--按照id删除一个资源
local function removeResourceById()
    local id = request:getNumParam("id", true, true)
    local result = service.removeResourceById(id)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "删除失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result }))
end

--按照分类删除所有资源
local function removeResourceByCategoryId()
    local id = request:getNumParam("category_id")
    local result = service.removeResourceByCategoryId(id)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "删除失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result }))
end

--删除分类和其下的资源
local function removeClassAndResources()
    local id = request:getNumParam("id", true, true)
    local result = service.removeClassAndResources(id)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "删除失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result }))
end

--万能查询记录
local function getResourcesByKinds()
    local category_id = request:getNumParam("category_id", true, true)
    local name = request:getStrParam("name", false, false)
    local page_size = request:getNumParam("page_size", true, true)
    local page_num = request:getNumParam("page_num", true, true)
    local stage_id = request:getNumParam("stage_id", true, true)
    local start_time = request:getStrParam("start_time", false, false)
    local end_time = request:getStrParam("end_time", true, true)
    local subject_id = request:getStrParam("subject_id", true, true)
    local zip_status = request:getStrParam("zip_status", false, false)
    local scheme_id = request:getNumParam("scheme_id", false, false);
    local volume_id = request:getNumParam("volume_id", false, false);
    local chapter_id = request:getNumParam("chapter_id", false, false);
    local section_id = request:getNumParam("section_id", false, false);
    --    local chapter = request:get
    if not name then
        name = ""
    end
    local param = {}
    if not volume_id or volume_id == "" then
        volume_id = ""
    end
    if not chapter_id or chapter_id == "" then
        chapter_id = ""
    end
    if not section_id or section_id == "" then
        section_id = ""
    end

    if not scheme_id and scheme_id == "" then
        scheme_id = ""
    end
    if zip_status and zip_status ~= "" then
        param.zip_status = zip_status
    end
    if category_id ~= -1 then
        param.category_id = category_id
    end
    if stage_id ~= -1 then
        param.stage_id = stage_id
    end
    if subject_id ~= -1 then
        param.subject_id = subject_id
    end
    param[1] = "1";
    local result, totalpage, total_row = service.getResourcesByKinds(param, name, page_size, page_num, start_time, end_time, scheme_id, volume_id, chapter_id, section_id)
    log:debug(totalpage)
    log:debug(page_num)
    local totalpageindex = totalpage
    if totalpage == nil or not totalpage then
        totalpageindex = 1
    end
    if totalpageindex < page_num then
        result, totalpage, total_row = service.getResourcesByKinds(param, name, page_size, totalpageindex, start_time, end_time, scheme_id, volume_id, chapter_id, section_id)
    end

    if not result or result == false then
        ngx.say(cjson.encode({ success = false, info = "获取列表失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, result = result, totalpage = totalpage, total_row = total_row, page_num = page_num, page_size = page_size }))
    return;
end

--更新类别
local function updateClass()
    local id = request:getNumParam("id", true, true)
    local param = getClassRequest()
    param.id = id

    local result = service.updateClass(param)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "更新失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end


--获取记录
local function getRecord()
    local param = getRecordRequest()

    local result = service.getRecord(param)
    if not result or result == false then
        ngx.say(cjson.encode({ success = result, info = "获取次数失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, times = result }))
    return;
end

--添加记录
local function addRecord()
    local client_type = request:getNumParam("client_type", true, true)
    local h5_resource_id = request:getNumParam("h5_resource_id", true, true)
    local param = {
        client_type = client_type,
        h5_resource_id = h5_resource_id
    }
    local result, id = service.writeRecord(param)
    if not result or result == false then
        ngx.say(cjson.encode({ success = false, info = "添加失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, id = id }))
    return;
end

--通过id获取资源
local function getResourceById()
    local id = request:getNumParam("id", true, true)
    local result = service.getResourceById(id)
    if not result or result == false then
        ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
        return;
    end
    if result then
        result['success'] = true
        ngx.say(cjson.encode(result))
    end
    return;
end

local function getCounts()
    local pc_count, mob_count, reg_count = service.getCounts()

    if not pc_count or not mob_count or not reg_count or pc_count == false then
        ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
        return;
    end
    if pc_count and mob_count and reg_count then
        ngx.say(cjson.encode({ success = true, pc_count = pc_count, mob_count = mob_count, reg_count = reg_count }))
    end
    return;
end

local function getVisitResourceCount()
    local stage_id = request:getNumParam("stage_id", false, false)
    local subject_id = request:getNumParam("subject_id", false, false)
    local page_num = request:getNumParam("page_num", true, true)
    local page_size = request:getNumParam("page_size", true, true)
    local category_id = request:getNumParam("category_id", false, false)
    local param = {}
    if stage_id and stage_id ~= "" then
        param.stage_id = stage_id
    end
    if subject_id and subject_id ~= "" then
        param.subject_id = subject_id
    end
    if category_id and category_id ~= "" then
        param.category_id = category_id
    end
    if next(param) == nil then
        param[1] = "1";
    end
    local result, totalpage, total_row = service.getVisitResourceCount(param, page_num, page_size)
    if not result or result == false then
        ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
        return;
    end
    if result then
        ngx.say(cjson.encode({ success = true, resultList = result, page_size = page_size, page_num = page_num, total_page = totalpage, total_row = total_row }))
    end
    return;
end

local function writeRecord()
    local resourceId = request:getNumParam("resourceId", true, true)
    local dataSource = request:getNumParam("dataSource", true, true)
    local zip_name = request:getStrParam("zip_name", true, true)
    local url = "http://video.edusoa.com/down/H5Res/" .. string.sub(zip_name, 1, 2) .. "/" .. zip_name .. "/index.html?resourceId=" .. resourceId .. "&dataSource=" .. dataSource
    ngx.redirect(url);
    return;
end

local function getSchemeInfoBySubject()
    local subject_id = request:getNumParam("subject_id", true, true)
    --local status, result = _SchemeSrv: getStandardSchemeBySubject(subject_id)
    local result = service.getSchemeInfoBySubject(subject_id)
    log:debug(result)
    if not result  then
        ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, version_list = result }))
    return;

end



local function getVolumeInfoByScheme()
    local scheme_id = request:getNumParam("scheme_id", true, true)
    --local volumeArray, schemeCache = catalogueSrv:getVolumeByScheme(scheme_id)
    local volumeArray, schemeCache = service.getVolumeInfoByScheme(scheme_id)
    log:debug(volumeArray)
    log:debug(schemeCache)
    if not volumeArray or not schemeCache then
        ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = true, volume_list = volumeArray, scheme_info = schemeCache }))
    return;
end

local function getChapterInfoBySchemeAndVolume()
    log:debug("ggggg")
    local scheme_id = request:getNumParam("scheme_id", true, true)
    local volume_id = request:getNumParam("id", true, true)
    local data = ngx.location.capture("/dsideal_yy/resource/getStructureAsyncInfo?scheme_id=" .. scheme_id .. "&id=" .. volume_id)
    log:debug("aaaaaa")
    log:debug(data)
    local _data;
    if data.status == 200 then
        _data = cjson.decode(data.body)
--        log:debug(_data)
--        log:debug(_data['ORG_NAME'])
        --local org_name = _data['ORG_NAME']
        --if org_name then
        --    return org_name
        --else
        --    return "获取学校名字失败"
        --end
        local result = service.getChapterInfoBySchemeAndVolume(_data,scheme_id,volume_id)
        if not result or result == false then
            ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
            return;
        end
        ngx.say(cjson.encode(result))
        return;
    end
    ngx.say(cjson.encode({ success = false, info = "获取失败，或操作有误" }))
    return;
end

local urls = {
    GET = {
        --        permission_no_context..'/demo1',demo1,
        permission_no_context .. '/getClassById', getClassById,
        permission_no_context .. '/getClassBySeq', getClassBySeq,
        permission_no_context .. '/getClasses', getClasses,
        permission_no_context .. '/getResourcesByKinds', getResourcesByKinds,
        permission_no_context .. '/getRecord', getRecord,
        permission_no_context .. '/getResourceById', getResourceById,
        permission_no_context .. '/getCounts', getCounts,
        permission_no_context .. '/getVisitResourceCount', getVisitResourceCount,
        permission_no_context .. '/writeRecord', writeRecord,
        '/e', index,
        permission_no_context .. '/getSchemeInfoBySubject', getSchemeInfoBySubject,
        permission_no_context .. '/getVolumeInfoByScheme', getVolumeInfoByScheme,
        permission_no_context .. '/getChapterInfoBySVolumelx', getChapterInfoBySchemeAndVolume,
    },
    POST = {
        --        management_context .. '/delete_boutique_lead$', deleteBoutiqueLead, --删除精品导学.
        management_context .. '/addClass', addClass,
        management_context .. '/removeClassById', removeClassById,
        management_context .. '/addResource', addResource,
        management_context .. '/updateResource', updateResource,
        management_context .. '/setResourceScheme', setResourceScheme,
        management_context .. '/removeResourceById', removeResourceById,
        management_context .. '/removeResourceByCategoryId', removeResourceByCategoryId,
        management_context .. '/removeClassAndResources', removeClassAndResources,
        management_context .. '/updateClass', updateClass,
        management_context .. '/addRecord', addRecord,
        management_context .. '/updateNames', updateNames
    }
}
local app = web.application(urls, nil)
app:start()
