<script>
    function initRefTable(spsContainer) {
        if (!spsContainer) {
            spsContainer = $('#ref_table');
        }
        spsContainer.html("");
        let refDefList = getRefDefList();
        createRefTableDiv(spsContainer, refDefList);
        spsContainer.find("select").each(function () {
            chosen_init_target($(this), "chosen-select-deselect");
        });
    }

    function createRefTableDiv(spsContainer, refDefList) {
        let ret = $("#template").find("[name='template_ref_table']").clone();
        spsContainer.append(ret);
        let defListDiv = ret.find("[name='ref_def_list']");
        defListDiv.on("change", function(){
//            if ($(this).height() >= window.innerHeight*0.45) {
//                $(this).css("max-height", window.innerHeight*0.45 + "px");
//                $(this).css("overflow-y", "scroll");
//            } else {
//                $(this).css("max-height", undefined);
//                $(this).css("overflow-y", "visible");
//            }
        });
        for (let i in refDefList) {
            creatRefDefDiv(refDefList[i], defListDiv);
        }
        initRefDefDiv(ret.find("[name='template_ref_def_new']"));
        ret.find("[name='auto_detect_btn']").on("click", function() {
            detectReferences(defListDiv);
        });
        return ret;
    }
    
    function creatRefDefDiv(refDef, defListDiv) {
//        return initRefDefDiv(null, refDef);
        let div = $("#template").find("[name='template_ref_def_readonly']").clone();
        let editBtn = div.find("[name='edit_btn']");
        let fromTableDiv = div.find("[name='reference_from_table']");
        let toTableDiv = div.find("[name='reference_to_table']");
        let fromKeyDiv = div.find("[name='reference_from_vars']");
        let toKeyDiv = div.find("[name='reference_to_vars']");
        if (Object.keys(templates).length > 1) {
//            fromTableDiv.html(refDef.from.file + "<br>-- " + refDef.from.sheet);
//            toTableDiv.html(refDef.to.file + "<br>-- " + refDef.to.sheet);
//            fromTableDiv.html('<span style="color:' + fileColors[refDef.from.file] + '"><a data-toggle="tooltip"  title="' + refDef.from.file + '" style="color:' + fileColors[refDef.from.file] + ';text-decoration: underline;">' + refDef.from.file.substring(0, 5) + "..." + '</a> -> ' + refDef.from.sheet + '</span>');
//            toTableDiv.html('<a data-toggle="tooltip"  title="' + refDef.to.file + '">' + refDef.to.file.substring(0, 5) + "..." + '</a> -> <span style="color:' + fileColors[refDef.to.file] + '">' + refDef.to.sheet + '</span>');
            fromTableDiv.html('<a data-toggle="tooltip" title="' + refDef.from.file + '" style="color:' + fileColors[refDef.from.file] + '">' + getTableLabel(getRefTableDef(refDef.from), refDef.from.file) + '</a>');
            toTableDiv.html('<a data-toggle="tooltip" title="' + refDef.to.file + '" style="color:' + fileColors[refDef.to.file] + '">' + getTableLabel(getRefTableDef(refDef.to), refDef.to.file) + '</a>');
        } else {
            fromTableDiv.html(getTableLabel(getRefTableDef(refDef.from), refDef.from.file));
            toTableDiv.html(getTableLabel(getRefTableDef(refDef.to), refDef.to.file));
        }
        setRefKeysDiv(fromKeyDiv, refDef.from);
        setRefKeysDiv(toKeyDiv, refDef.to);
        
        div.find("[name='ref_def_json']").val(JSON.stringify(refDef));
        editBtn.on("click", function() {
            div.remove();
            defListDiv.trigger("change");
            let fromKeyIdxs = getKeyIdxArr(refDef.from.keys);
            let toKeyIdxs = getKeyIdxArr(refDef.to.keys);
            let references = getRefTableDef(refDef.from).references;
            delete references[fromKeyIdxs][getRefDefKey(refDef.to, toKeyIdxs)];
            if (Object.keys(references[fromKeyIdxs]).length === 0) {
                delete references[fromKeyIdxs];
            }
            isChanged = true;
            isViewUpdated = false;
            isDebugViewUpdated = false;
        });
        defListDiv.append(div).trigger("change");
        return div;
    }
    
    function getKeyIdxArr(keys, mappings) {
        let keyIdxs = [];
        if (mappings) {
            for (let i in keys) {
                if (keys[i].column_header) {
                    let found = false;
                    for (let j in mappings) {
                        if (mappings[j].column_header === keys[i].column_header) {
                            keyIdxs.push(Number(mappings[j].column_index));
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        keyIdxs.push(Number(keys[i].column_index));
                    }
                } else {
                    keyIdxs.push(Number(keys[i].column_index));
                }
            }
        } else {
            for (let i in keys) {
                keyIdxs.push(Number(keys[i].column_index));
            }
        }
        return keyIdxs;
    }
    
    function getKeyArr(keyIdxs, mappings, isOrgIdx) {
        let keys = [];
        if (!mappings) {
            mappings = getCurTableDef().mappings;
        }
        for (let i in keyIdxs) {
            for (let j in mappings) {
                if (Number(keyIdxs[i]) === mappings[j].column_index) {
                    if (isOrgIdx) {
                        let tmp = Object.assign({}, mappings[j]);
                        if (tmp.column_index_org) {
                            tmp.column_index = tmp.column_index_org;
                            delete tmp.column_index_org;
                        } else {
                            delete tmp.column_index;
                        }
                        keys.push(tmp);
                    } else {
                        keys.push(mappings[j]);
                    }
                    break;
                }
            }
        }
        return keys;
    }
    
    function setRefKeysDiv(div, refDef) {
        let mappings = getRefTableDef(refDef).mappings;
        let text = [];
        for (let i in refDef.keys) {
            for (let j in mappings) {
                if (mappings[j].column_index === refDef.keys[i].column_index) {
                    text.push(getVarNameLabel(mappings[j]));
                    break;
                }
            }
        }
        div.html(text.join("<br>"));
    }

    function initRefDefDiv(div, refDef) {
        let isNewKeyDiv = true;
        let defListDiv;
        if (!div) {
            div = $("#template").find("[name='template_ref_def']").clone();
            isNewKeyDiv = false;
        }
        if (isNewKeyDiv) {
            defListDiv = div.prev();
        }
        let editBtn = div.find("[name='edit_btn']");
        let fromTableSB = div.find("[name='reference_from_table']");
        let toTableSB = div.find("[name='reference_to_table']");
        let fromKeySB = div.find("[name='reference_from_vars']");
        let toKeySB = div.find("[name='reference_to_vars']");
        let singleCB = div.find("[name='meta_table_flg']");
        
        if (refDef) {
            initTableSB(fromTableSB, refDef.from);
            initTableSB(toTableSB, refDef.to);
            initKeySB(fromKeySB, JSON.parse(fromTableSB.val()));
            initKeySB(toKeySB, JSON.parse(toTableSB.val()));
            setKeySB(fromKeySB, refDef.from.keys);
            setKeySB(toKeySB, refDef.to.keys);
        } else {
            initTableSB(fromTableSB);
            initTableSB(toTableSB);
        }
        
        fromTableSB.on("change", function() {
            let val = $(this).val();
            if (!val) {
                fromKeySB.val([]).prop("disabled", true).trigger("chosen:updated").trigger("change");
                toTableSB.find("option").prop("disabled", false).trigger("chosen:updated");
            } else {
                let refDefTable = JSON.parse(val);
                fromKeySB.prop("disabled", singleCB.prop("checked"));
                initKeySB(fromKeySB, refDefTable);
                if (toTableSB.val() === val) {
                    toTableSB.val("");
                }
                toTableSB.find("option").each(function () {
                    $(this).prop("disabled", $(this).val() === val);
                }).trigger("chosen:updated");
            }
        });
        fromKeySB.on("change", function() {
            if (!toTableSB.val()) {
                return;
            }
            let refDefTable = JSON.parse(toTableSB.val());
            let vals = $(this).val();
            if (vals.length > 0) {
                let mappingsTo = getRefTableDef(refDefTable).mappings;
                refDefTable = JSON.parse(fromTableSB.val());
                let mappingsFrom = getRefTableDef(refDefTable).mappings;
                let keys = [];
                for (let i in vals) {
                    for (let j in mappingsFrom) {
                        if (Number(vals[i]) === mappingsFrom[j].column_index) {
                            keys.push(mappingsFrom[j]);
                            break;
                        }
                    }
                }
                let valsTo = [];
                for (let i in keys) {
                    for (let j in mappingsTo) {
                        if ((keys[i].icasa
                                && (keys[i].icasa === mappingsTo[j].icasa
                                || keys[i].icasa === mappingsTo[j].column_header))
                            || (keys[i].column_header
                                && (keys[i].column_header === mappingsTo[j].icasa
                                || keys[i].column_header === mappingsTo[j].column_header)
                            )) {
                            valsTo.push(mappingsTo[j].column_index + "");
                            break;
                        }
                    }
                }
                toKeySB.val(valsTo).trigger("chosen:updated").trigger("change");
            } else {
                
            }
        });
        toTableSB.on("change", function() {
            let val = $(this).val();
            if (!val) {
                singleCB.prop("checked", false).prop("disabled", true);
                toKeySB.val([]).prop("disabled", true).trigger("chosen:updated").trigger("change");
            } else {
                let refDefTable = JSON.parse(val);
//                if (getRefTableDef(refDefTable).single_flg) {
                    singleCB.prop("disabled", false);
//                } else {
//                    singleCB.prop("disabled", true);
//                    if (singleCB.prop("checked")) {
//                        singleCB.prop("checked", false).trigger("change");
//                    }
//                }
                toKeySB.prop("disabled", singleCB.prop("checked"));
                initKeySB(toKeySB, refDefTable);
                fromKeySB.trigger("change");
            }
        });
        toKeySB.on("change", function() {
            if (toKeySB.val().length === 0) {
                editBtn.prop("disabled", true);
            } else if (toKeySB.val().length !== fromKeySB.val().length) {
                editBtn.prop("disabled", true);
            } else if (isRefDefExistDiv(div)) {
                editBtn.prop("disabled", true);
            } else {
                editBtn.prop("disabled", false);
            }
        });
        if (isNewKeyDiv) {
            singleCB.on("change", function() {
                let isChecked = singleCB.prop("checked");
                fromKeySB.val([]).prop("disabled", isChecked).trigger("chosen:updated");
                toKeySB.val([]).prop("disabled", isChecked).trigger("chosen:updated");
                editBtn.prop("disabled", !isChecked);
            });
            editBtn.prop("disabled", true).on("click", function() {
                let fromTable = JSON.parse(fromTableSB.val());
                let fromKeyIdxs = fromKeySB.val();
                let toTable = JSON.parse(toTableSB.val());
                let toKeyIdxs = toKeySB.val();
                let newRefDef = createRefDefObj(fromTable, fromKeyIdxs, toTable, toKeyIdxs);
                
                let references = getRefTableDef(fromTable).references;
                if (!references[fromKeyIdxs]) {
                    references[fromKeyIdxs] = {};
                }
                references[fromKeyIdxs][getRefDefKey(toTable, toKeyIdxs)] = newRefDef.to;
                
                creatRefDefDiv(newRefDef, defListDiv);
                fromTableSB.val([]).trigger("chosen:updated").trigger("change");
                toTableSB.val([]).trigger("chosen:updated").trigger("change");
                isChanged = true;
                isViewUpdated = false;
                isDebugViewUpdated = false;
            });
        } else {
            editBtn.on("click", function() {
                isChanged = true;
                isViewUpdated = false;
                isDebugViewUpdated = false;
            });
        }
        return div;
    }
    
    function createRefDefObj(fromTable, fromKeyIdxs, toTable, toKeyIdxs, isOrgIdx) {
        return {
            from:{
                file : fromTable.file,
                sheet : fromTable.sheet,
                table_index : fromTable.table_index,
                keys : getKeyArr(fromKeyIdxs, getRefTableDef(fromTable).mappings, isOrgIdx)
            },
            to:{
                file : toTable.file,
                sheet : toTable.sheet,
                table_index : toTable.table_index,
                keys : getKeyArr(toKeyIdxs, getRefTableDef(toTable).mappings, isOrgIdx)
            }
        };
    }
    
    function setKeySB(sb, keys) {
        let vals = [];
        for (let i in keys) {
            vals.push(keys[i].column_index);
        }
        sb.val(vals);
    }
    
    function initTableSB(sb, refDef) {
        let val = sb.val();
        if (refDef) {
            val = createRefSheetTaregetKeyStr(refDef.file, refDef.sheet, refDef.table_index);
        }
        sb.html('<option value=""></option>');
        let optGrp = null;
        loopTables(
            function(fileName){
                optGrp = $('<optgroup name="' + fileName + '" label="' + fileName + '"></optgroup>');
            },
            null,
            function(fileName, sheetName, i, tableDef) {
                let lable = getTableLabel(tableDef, fileName);
                if (lable !== fileName) {
                    let opt = $('<option value=\'' + createRefSheetTaregetKeyStr(fileName, sheetName, tableDef.table_index) + '\'>' + lable + '</option>');
                    optGrp.append(opt);
                } else {
                    optGrp = null;
                    sb.append($('<option value=\'' + createRefSheetTaregetKeyStr(fileName, sheetName, tableDef.table_index) + '\'>' + lable + '</option>'));
                }
            },
            null,
            function(fileName) {
                if (optGrp !== null) {
                    sb.append(optGrp);
                }
            }
        );
        sb.val(val).trigger("chosen:updated");
        if (refDef) {
            sb.trigger("change");
        }
    }

    function getTableLabel(tableDef, fileName) {
        let label;
        if (fileName.toLowerCase().endsWith(".csv") || tableDef === null) {
            label = fileName;
        } else {
            label = tableDef.sheet_name;
        }
        if (isSubTableExistInSheet(getSheetDef(fileName, tableDef.sheet_name))) {
            if (tableDef.table_name) {
                label += "__" + tableDef.table_name;
            } else {
                label += "__table_" + tableDef.table_index;
            }
        }
        return label;
    }
    
    function initKeySB(sb, refDef) {
        if (!refDef || !refDef.file || !refDef.sheet) {
            return;
        }
        let mappings = getRefTableDef(refDef).mappings;
        let val = [];
        if (refDef && refDef.keys) {
            val = createRefKeyTaregetKeyStr(refDef.keys);
        }
        sb.html('<option value=""></option>');
        for (let i in mappings) {
            if (mappings[i].column_index_org) {
                let opt = $('<option value="' + mappings[i].column_index + '">' + getVarNameLabel(mappings[i]) + '</option>');
                sb.append(opt);
            }
        }
        sb.val(val).trigger("chosen:updated");
    }
    
    function isRefDefExistDiv(refDefDiv) {
        let fromTableSB = refDefDiv.find("[name='reference_from_table']");
        let toTableSB = refDefDiv.find("[name='reference_to_table']");
        let fromKeySB = refDefDiv.find("[name='reference_from_var']");
        let toKeySB = refDefDiv.find("[name='reference_to_var']");
        isRefDefExist(JSON.parse(fromTableSB.val()), fromKeySB.val(), JSON.parse(toTableSB.val()), toKeySB.val());
    }
    
    function isRefDefExist(fromTable, fromKeyIdxs, toTable, toKeyIdxs) {
        let references = getRefTableDef(fromTable).references;
        return !!references[fromKeyIdxs] && !!references[fromKeyIdxs][getRefDefKey(toTable, toKeyIdxs)];
    }
    
    function getRefDefKey(table, keyIdxs) {
        if (!table.table_index) {
            table.table_index = 1;
        }
        return "[" + table.file + "][" + table.sheet + "][" + table.table_index + "]:" + keyIdxs;
    }
    
    function createRefSheetTaregetKeyStr(fileName, sheetName, table_index) {
        let keyObj = {
            file : fileName,
            sheet : sheetName,
            table_index : table_index
        };
        if (!table_index) {
            keyObj.table_index = 1;
        }
        return JSON.stringify(keyObj);
    }
    
    function createRefKeyTaregetKeyStr(keys) {
        let keyObj = [];
        for (let i in keys) {
            keyObj.push(keys[i].column_index);
        }
        return JSON.stringify(keyObj);
    }
    
    function getVarNameLabel(mapping) {
        if (mapping.vars) {
            let ret = [];
            for (let i in mapping.vars) {
                ret.push(getVarNameText(mapping.vars[i]));
            }
            return ret.join("; ");
        } else {
            return getVarNameText(mapping);
        }
    }
    
    function getVarNameText(mapping) {
        let header = mapping.column_header;
        let icasa = mapping.icasa;
        let index = mapping.column_index;
        let ret;
        if (header) {
            if (icasa && icasa.toLowerCase() !== header.toLowerCase()) {
                ret = '[' + index + '] ' + header + '->' + icasa;
            } else {
                ret = '[' + index + '] ' + header;
            }
        } else if (icasa) {
            ret = '[' + index + '] ' + icasa;
        } else {
            ret = 'Column ' + index;
        }
        return ret;
    }
    
    function getRefDefList() {
        let ret = [];
        loopTables(null, null, function(fileName, sheetName, i, tableDef) {
            for (let keyIdxs in tableDef.references) {
                let refDefFrom = {
                    file: fileName,
                    sheet: sheetName,
                    table_index:tableDef.table_index,
                    keys: getKeyArr(JSON.parse("[" + keyIdxs + "]"), tableDef.mappings)
                };
                let refDefTo = tableDef.references[keyIdxs];
                for (let refDefKey in refDefTo) {
                    ret.push({
                        from: refDefFrom,
                        to: refDefTo[refDefKey]
                    });
                }
            }
        });
        return ret;
    }
    
    function detectReferences(defListDiv) {
        confirmBox("This process will overwrite the exisiting reference configuration.", function() {
            loopTables(null, null, function(fileName, sheetName, i, tableDef) {
                tableDef.references = {};
            });
            defListDiv.html("").trigger("change");
            let tableRanks = getTableRanks();
            let rootRankArr;
            // Check general references from lowest rank to highest rank
            for (let i = tableRanks.length - 1; i >= 0; i--) {
                let tableRankArr = tableRanks[i];
                if (!tableRankArr) {
                    continue;
                }
                rootRankArr = tableRankArr;
                for (let j in tableRankArr) {
                    let tableRank = tableRankArr[j];
                    let newRefDef= detectReference(tableRanks, tableRank, tableRank.order, true);
                    if (newRefDef && newRefDef !== true) {
                        creatRefDefDiv(newRefDef, defListDiv);
                    }
                }
            }
            // Check global information case
            for (let i = 0; i <= tableRanks.length - 1; i++) {
                let tableRankArr = tableRanks[i];
                if (!tableRankArr) {
                    continue;
                }
                for (let j in tableRankArr) {
                    let tableRank = tableRankArr[j];
                    let newRefDef= detectReference(tableRanks, tableRank, tableRank.order, false);
                    if (newRefDef && newRefDef !== true) {
                        creatRefDefDiv(newRefDef, defListDiv);
                    }
                }
            }
        });
    }

//    function detectReference(tableRank, order, lookForParent) {
    function detectReference(tableRanks, tableRank, order, lookForParent) {
        let newRefDef = null;
        let catDef = icasaVarMap.getIcasaDataCatDef(order);
        let lookupOrders;
        if (lookForParent) {
            lookupOrders = catDef.parent;
        } else {
            lookupOrders = catDef.child;
        }
        if (!lookupOrders) {
            return newRefDef;
        }
        // Check direct relations
        let directTableRanks;
        if (lookForParent) {
            directTableRanks = tableRanks[catDef.rank - 1];
        } else {
            directTableRanks = tableRanks[catDef.rank + 1];
        }
        if (directTableRanks) {
            for (let i in directTableRanks) {
                let lookupTableRank = directTableRanks[i];
                if (lookupOrders.includes(lookupTableRank.order)) {
                    newRefDef = createReference(lookupTableRank, tableRank);
                    if (newRefDef) {
                        return newRefDef;
                    }
                }
            }
        }
        // Check ground relations
        for (let k in lookupOrders) {
            newRefDef = detectReference(tableRanks, tableRank, lookupOrders[k], lookForParent);
            if (newRefDef) {
                return newRefDef;
            }
        }
        return newRefDef;
    }
    
    function createReference(fromDef, toDef) {
        let ret = null;
        if (!fromDef.table_index) {
            fromDef.table_index = 1;
        }
        if (!toDef.table_index) {
            toDef.table_index = 1;
        }
        let from = getRefTableDef(fromDef);
        let to = getRefTableDef(toDef);
        let toKeyIdxs = [];
        let fromKeyIdxs = [];
        if (from.mappings.length === 0 || to.mappings.length === 0) {
            return ret;
        }
        // Check if global table is already linked with child table with keys
        for (let fromKeyIdx in from.references) {
            for (let toKey in from.references[fromKeyIdx]) {
                let refDef = from.references[fromKeyIdx][toKey];
                if (refDef.file === toDef.file &&
                        refDef.sheet === toDef.sheet &&
                        refDef.table_index === toDef.table_index) {
                    return true;
                }
            }
        }
        for (let fromKeyIdx in to.references) {
            for (let toKey in to.references[fromKeyIdx]) {
                let refDef = to.references[fromKeyIdx][toKey];
                if (refDef.file === fromDef.file &&
                        refDef.sheet === fromDef.sheet &&
                        refDef.table_index === fromDef.table_index) {
                    return true;
                }
            }
        }
        for (let i in to.mappings) {
            let toIcasa = to.mappings[i].icasa;
            let toHeader = to.mappings[i].column_header;
            if (!toIcasa && !toHeader || !to.mappings[i].column_index_org) {
                continue;
            }
            for (let j in from.mappings) {
                let fromIcasa = from.mappings[j].icasa;
                let fromHeader = from.mappings[j].column_header;
                if (!fromIcasa && !fromHeader) {
                    continue;
                }
                if (fromIcasa  && (fromIcasa  === toIcasa  || fromIcasa  === toHeader)
                 || fromHeader && (fromHeader === toHeader || fromHeader === toIcasa)) {
                    fromKeyIdxs.push(from.mappings[j].column_index);
                    toKeyIdxs.push(to.mappings[i].column_index);
                    break;
                }
            }
        }
        if (fromKeyIdxs.length === 0 && !to.single_flg) {
            return ret;
        } else {
            if (!from.references) {
                from.references = {};
            }
            let references = from.references;
            if (!references[fromKeyIdxs]) {
                references[fromKeyIdxs] = {};
            }
            let newRefDef = createRefDefObj(
                {file: fromDef.file, sheet: fromDef.sheet, table_index: fromDef.table_index},
                fromKeyIdxs,
                {file: toDef.file, sheet: toDef.sheet, table_index: toDef.table_index},
                toKeyIdxs);
            references[fromKeyIdxs][getRefDefKey(
                {file: toDef.file, sheet: toDef.sheet, table_index: toDef.table_index},
                toKeyIdxs)] = newRefDef.to;
            ret = newRefDef;
        }
        return ret;
    }
    
    function getTableRanks() {
        let ret = [];
        loopTables(null, null, function(fileName, sheetName, i, tableDef) {
            let catObj = getTableCategory(tableDef.mappings);
            catObj.file = fileName;
            catObj.sheet = sheetName;
            catObj.table_index = tableDef.table_index;
            if (!ret[catObj.rank]) {
                ret[catObj.rank] = [];
            }
            ret[catObj.rank].push(catObj);
        });
        return ret;
        
    }
    
    function getTableCategory(mappings) {
        let ret = {rank : -1, category : "unknown"};
        for (let i in mappings) {
            if (mappings[i].ignored_flg || !mappings[i].column_index_org || (mappings[i].icasa && ["exname", "soil_id", "wst_id"].includes(mappings[i].icasa.toLowerCase()))) {
                continue;
            }
            let retCat = icasaVarMap.getCategory(mappings[i]);
            if (retCat.rank > 0 && (ret.rank < 0 || ret.rank > retCat.rank)) {
                ret = retCat;
            }
        }
        return ret;
    }
    
    function isArrayData(mappings) {
        let tableCat = getTableCategory(mappings);
        if (tableCat.rank === 3) {
            return tableCat.order > 2500;
        } else if (tableCat.rank === 4) {
            return tableCat.order < 2500;
        } else if (tableCat.rank === 6) {
            return tableCat.order > 5050;
        } else {
            return tableCat.rank === 7;
        }
    }
</script>

<div id="template" hidden>
    <div name="template_ref_table">
        <div class="row text-left">
            <div class="col-sm-12 ">
                <button type="button" class="btn btn-primary" name="auto_detect_btn">
                    <span class="glyphicon glyphicon-search"></span> Auto Detect Reference 
                </button>
            </div>
        </div>
        <div class="panel panel-info" name="">
            <div class="panel-heading">
                <div class="row" style="padding: 0px">
                    <div class="col-sm-11">
                        <div class="row" style="padding: 0px">
                            <div class="col-sm-6 text-left">
                                <span class="label label-primary">From</span> (The lookup value will be read from this table)
                                <hr>
                                <div class="row" style="padding: 0px">
                                    <div class="col-sm-6 text-left"><span class="label label-primary">Sheet</span></div>
                                    <div class="col-sm-6 text-left"><span class="label label-primary">Variable</span></div>
                                </div>
                            </div>
                            <div class="col-sm-6 text-left">
                                <span class="label label-primary">To</span> (The lookup value will be used to search records in this table)
                                <hr>
                                <div class="row" style="padding: 0px">
                                    <div class="col-sm-6 text-left"><span class="label label-primary">Sheet</span></div>
                                    <div class="col-sm-6 text-left"><span class="label label-primary">Variable</span></div>
                                </div>
                            </div>
                        </div>

                    </div>
                    <div class="col-sm-1"><span class="label label-primary">Edit</span></div>
                </div>

    <!--            <div class="row" style="padding: 0px">
                    <div class="col-sm-11">
                        <div class="col-sm-6 text-left"><span class="label label-primary">From</span></div>
                        <div class="col-sm-6 text-left"><span class="label label-primary">To</span></div>
                    </div>
                    <div class="col-sm-1"><span class="label label-primary">Edit</span></div>
                </div><div class="row" style="padding: 0px">
                    <div class="col-sm-11">
                        <div class="col-sm-3 text-left"><span class="label label-primary">Sheet</span></div>
                        <div class="col-sm-3 text-left"><span class="label label-primary">Variable</span></div>
                        <div class="col-sm-3 text-left"><span class="label label-primary">Sheet</span></div>
                        <div class="col-sm-3 text-left"><span class="label label-primary">Variable</span></div>
                    </div>
                </div>-->
            </div>
            <div class="panel-body">
                <div class="row">
                    <div name="ref_def_list"></div>
                    <div name="template_ref_def_new" class="row" style="padding-top: 10px">
                        <div class="col-sm-11">
                            <div class="col-sm-3">
                                <select class="form-control" name="reference_from_table" data-placeholder="Choose ...">
                                    <option value=""></option>
                                </select>
                            </div>
                            <div class="col-sm-3">
                                <select class="form-control" name="reference_from_vars" data-placeholder="Choose ..." multiple disabled>
                                    <option value=""></option>
                                </select>
                            </div>
                            <div class="col-sm-3">
                                <select class="form-control" name="reference_to_table" data-placeholder="Choose ...">
                                    <option value=""></option>
                                </select>
                            </div>
                            <div class="col-sm-3">
                                <select class="form-control" name="reference_to_vars" data-placeholder="Choose ..." multiple disabled>
                                    <option value=""></option>
                                </select>
                            </div>
                            <div class="col-sm-6 col-sm-offset-6">
                                <input type="checkbox" name="meta_table_flg" disabled> Apply the data in this table as global information to every record in "From" table.
                            </div>
                        </div>
                        <div class="col-sm-1">
                            <button type="button" name="edit_btn" class="btn btn-primary btn-sm"><span class="glyphicon glyphicon-plus"></span></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div name="template_ref_def" class="row">
        <div class="col-sm-11">
            <div class="col-sm-3">
                <select class="form-control" name="reference_from_table" data-placeholder="Choose ..." disabled>
                    <option value=""></option>
                </select>
            </div>
            <div class="col-sm-3">
                <select class="form-control" name="reference_from_vars" data-placeholder="Choose ..." multiple disabled>
                    <option value=""></option>
                </select>
            </div>
            <div class="col-sm-3">
                <select class="form-control" name="reference_to_table" data-placeholder="Choose ..." disabled>
                    <option value=""></option>
                </select>
            </div>
            <div class="col-sm-3">
                <select class="form-control" name="reference_to_vars" data-placeholder="Choose ..." multiple disabled>
                    <option value=""></option>
                </select>
            </div>
        </div>
        <div class="col-sm-1">
            <button type="button" name="edit_btn" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
        </div>
    </div>
    <div name="template_ref_def_readonly" >
        <div class="row">
            <div class="col-sm-11">
                <div class="col-sm-3">
                    <div name="reference_from_table" style="overflow-wrap:break-word"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_from_vars" style="overflow-wrap:break-word"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_to_table" style="overflow-wrap:break-word"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_to_vars" style="overflow-wrap:break-word"></div>
                </div>
            </div>
            <input type='hidden' name='ref_def_json'>
            <div class="col-sm-1">
                <button type="button" name="edit_btn" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
            </div>
        </div>
        <hr>
    </div>
</div>