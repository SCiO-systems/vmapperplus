package com.scio.ontovmapper.util;

import au.com.bytecode.opencsv.CSVReader;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.scio.ontovmapper.OlsApiClient;
import com.scio.ontovmapper.model.Term;
import org.agmip.tool.vmapper.util.JSONObject;
import org.agmip.tool.vmapper.util.Path;

import java.io.*;
import java.util.ArrayList;

public class OntologyTermManager {

    public static JsonNode loadOntologyTerms() throws Exception {
        JsonNode res = null;

        File file = Path.Folder.getOntologyTermFile();
        if (!file.exists()) {
            OlsApiClient client = OlsApiClient.getInstance();
            ArrayList<Term> terms = client.getOntologyTerms("agro");
            updateOntologyTerms(terms);
        }

        try {
            CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',');
            String[] line = null;
            String value = null;
            ArrayList<Term> importedTerms = new ArrayList<Term>();

            while ((line = reader.readNext()) != null) {
                Term term = new Term(line[0],line[2],line[1]);
                importedTerms.add(term);
            }

            reader.close();
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ObjectMapper mapper = new ObjectMapper();

            res = mapper.valueToTree(importedTerms);

        }
        catch (IOException ioe) {
            ioe.printStackTrace(System.out);
        }
        System.out.println(res.toPrettyString());
        return res;
    }

    public static ArrayList<Term> loadOntologyTermsAsList() throws Exception {
        ArrayList<Term> importedTerms = new ArrayList<Term>();
        File file = Path.Folder.getOntologyTermFile();
        if (!file.exists()) {
            OlsApiClient client = OlsApiClient.getInstance();
            ArrayList<Term> terms = client.getOntologyTerms("agro");
            updateOntologyTerms(terms);
        }

        try {
            CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',');
            String[] line = null;

            while ((line = reader.readNext()) != null) {
                Term term = new Term(line[0],line[2],line[1]);
                importedTerms.add(term);
            }

            reader.close();
        }
        catch (IOException ioe) {
            ioe.printStackTrace(System.out);
        }

        return importedTerms;
    }

    public static void updateOntologyTerms(ArrayList<Term> terms) {
        try {
            FileWriter writer = new FileWriter(Path.Folder.getOntologyTermFile());
            for (Term term : terms) {
                String row = term.getIri() + "," + term.getId() + "," + term.getLabel() + "\n";
                writer.write(row);
            }
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
