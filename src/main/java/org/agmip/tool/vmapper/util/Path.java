package org.agmip.tool.vmapper.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.nio.file.Paths;
import java.util.HashMap;
import lombok.*;

public class Path {

    // The @Getter methods are needed in order to access
    public static class Web {
        @Getter public static final String INDEX = "/index";
        @Getter public static final String REGISTER = "/register";
        @Getter public static final String LOGIN = "/login";
        @Getter public static final String LOGOUT = "/logout";
        @Getter public static final String UPLOAD = "/upload";
        
        public static class Tools {
            @Getter private static final String PACKAGE = "/" + Tools.class.getSimpleName().toLowerCase();
            @Getter public static final String UNIT_MASTER = PACKAGE + "/unit";
            @Getter public static final String DATA_FACTORY = PACKAGE + "/data_factory";
            @Getter public static final String VMAPPER = PACKAGE + "/vmapper";
        }
        
        public static class Data {
            private static final String PACKAGE = "/" + Data.class.getSimpleName().toLowerCase();
            public static final String UNIT_LOOKUP = PACKAGE + "/unit/lookup";
            public static final String UNIT_CONVERT = PACKAGE + "/unit/convert";
            public static final String LOAD_FILE = PACKAGE + "/util/load_file";
        }
    }
    
    public static class Template {
        public final static String INDEX = "index.ftl";
        public final static String REGISTER = "register.ftl";
        public final static String LOGIN = "login.ftl";
        public final static String UPLOAD = "upload.ftl";
        public static final String NOT_FOUND = "notFound.ftl";
        
        public static class Demo {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String UNIT_MASTER = PACKAGE + "/unit_master.ftl";
            public static final String DATA_FACTORY = PACKAGE + "/data_factory.ftl";
        }
        
        public static class Translator {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String DSSAT_EXP = PACKAGE + "/xfile_template.ftl";
        }
    }
    
    public static class Folder {
        public final static String DATA_DIR = Config.get("DATA_DIR"); //"Data";
        public final static String ICASA_DIR = Config.get("ICASA_DIR"); //"ICASA";
        public final static String ONTO_DIR = Config.get("ONTO_DIR"); //"Terms";
        public final static String ICASA_CROP_CODE = Config.get("ICASA_CROP_CODE"); //"Crop_codes.csv";
        public final static String ICASA_MGN_CODE = Config.get("ICASA_MGN_CODE"); //"Management_codes.csv";
        public final static String ICASA_OTH_CODE = Config.get("ICASA_OTH_CODE"); //"Other_codes.csv";
        public final static String ICASA_MGN_VAR = Config.get("ICASA_MGN_VAR"); //"Management_info.csv";
        public final static String ICASA_OBV_VAR = Config.get("ICASA_OBV_VAR"); //"Measured_data.csv"
        public final static String ONTO_TERMS = Config.get("ONTO_TERMS"); // Terms.csv
        public final static int DEF_PORT = Integer.parseInt(Config.get("DEF_PORT")); //8081;

        public static File getCropCodeFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_CROP_CODE).toFile();
            return ret;
        }
        
        public static File getICASAFile(String sheetName) {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, sheetName + ".csv").toFile();
            return ret;
        }
        
        public static File getICASAMgnCodeFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_MGN_CODE).toFile();
            return ret;
        }
        
        public static File getICASAOthCodeFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_OTH_CODE).toFile();
            return ret;
        }
        
        public static File getICASAMgnVarFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_MGN_VAR).toFile();
            return ret;
        }
        
        public static File getICASAObvVarFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_OBV_VAR).toFile();
            return ret;
        }

        public static File getOntologyTermFile() {
            File ret = Paths.get(DATA_DIR, ONTO_DIR, ONTO_TERMS).toFile();
            return ret;
        }
    }
    
    public static class Config {
        private final static HashMap<String, String> CONFIGS = readConfig();
        private static HashMap<String, String> readConfig() {
            HashMap<String, String> ret = new HashMap();
            ret.put("DATA_DIR", "Data");
            ret.put("ICASA_DIR", "ICASA");
            ret.put("ONTO_DIR", "TERMS");
            ret.put("ICASA_MGN_CODE", "Management_codes.csv");
            ret.put("ICASA_OTH_CODE", "Other_codes.csv");
            ret.put("ICASA_MGN_VAR", "Management_info.csv");
            ret.put("ICASA_OBV_VAR", "Measured_data.csv");
            ret.put("ONTO_TERMS", "Terms.csv");
            ret.put("DEF_PORT", "8081");
            try {
                BufferedReader br = new BufferedReader(new FileReader(new File("config.ini")));
                String line;
                while ((line = br.readLine()) != null) {
                    int dividerIdx = line.indexOf("=");
                    if (dividerIdx > 0) {
                        String key = line.substring(0, dividerIdx).trim();
                        String value = line.substring(dividerIdx + 1).trim();
                        if (!value.isEmpty()) {
                            ret.put(key, value);
                        }
                    }
                }
            } catch(Exception ex) {
                ex.printStackTrace(System.err);
            }
            System.out.println("Load config as " + ret.toString());
            return ret;
        }
        public static String get(String key) {
            String ret = CONFIGS.get(key);
            if (ret == null) {
                ret = "";
            }
            return ret;
        }
    }
}
