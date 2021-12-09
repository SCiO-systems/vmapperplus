package com.scio.ontovmapper;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.eclipse.jetty.client.HttpClient;
import org.eclipse.jetty.client.api.ContentResponse;
import org.eclipse.jetty.util.ssl.SslContextFactory;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Iterator;
import com.scio.ontovmapper.model.Term;

public class OlsApiClient extends HttpClient {

    private static SslContextFactory.Client sslContextFactory = new SslContextFactory.Client();
    private static OlsApiClient olsClient = null;
    private static StringBuilder ontologies = new StringBuilder();

    public static OlsApiClient getInstance() throws Exception {
        if (olsClient == null)
            olsClient = new OlsApiClient(sslContextFactory);
        return olsClient;
    }

    public void init() throws Exception {
        olsClient.start();
    }

    public void close() throws Exception {
        olsClient.stop();
    }

    private OlsApiClient(SslContextFactory.Client factory) throws Exception {
        super(factory);
    }

    public String getAvailableCalls() throws Exception {
        ContentResponse res = olsClient.GET("http://www.ebi.ac.uk/ols/api");

        return res.getContentAsString();
    }

    public String getOntologies() throws Exception {
        ContentResponse res = olsClient.GET("http://www.ebi.ac.uk/ols/api/ontologies");

        return res.getContentAsString();
    }

    public String searchByTerm(String term) throws Exception {
        String query = "q=" + term ;

        ContentResponse res = olsClient.GET("http://www.ebi.ac.uk/ols/api/search?" + query);

        return res.getContentAsString();
    }

    public ArrayList<Term> getOntologyTerms(String ontologyCode) throws Exception {
        ArrayList<Term> terms = new ArrayList<Term>();
        ObjectMapper mapper = new ObjectMapper();
        int currentPage = 0;

        olsClient.start();
        ContentResponse res = olsClient.GET("http://www.ebi.ac.uk/ols/api/ontologies/" + ontologyCode + "/terms");

        JsonNode node = mapper.readTree(res.getContentAsString());
        int totalPages = node.get("page").get("totalPages").asInt();
        System.out.println("there are " + totalPages + " pages of terms in " + ontologyCode);

        Iterator termNodes = node.get("_embedded").get("terms").elements();
        while (termNodes.hasNext()) {
            JsonNode current = (JsonNode) termNodes.next();
            Term newTerm = new Term(current.get("iri").asText(), current.get("label").asText(), current.get("obo_id").asText());
            terms.add(newTerm);
        }
        while (currentPage < (totalPages-1)) {
            currentPage++;
            System.out.println("fetching page " + currentPage + " of " + ontologyCode + " terms");
            res = olsClient.GET("http://www.ebi.ac.uk/ols/api/ontologies/" + ontologyCode + "/terms?page=" + currentPage);
            node = mapper.readTree(res.getContentAsString());
            termNodes = node.get("_embedded").get("terms").elements();
            while (termNodes.hasNext()) {
                JsonNode current = (JsonNode) termNodes.next();
                Term newTerm = new Term(current.get("iri").asText(), current.get("label").asText(), current.get("obo_id").asText());
                terms.add(newTerm);
            }
        }
        olsClient.stop();
        return terms;
    }

    public String selectMatchingTerms(String seed) throws Exception {

        ContentResponse res = olsClient.GET("http://www.ebi.ac.uk/ols/api/select?q=" + seed + "&ontology=" + ontologies.toString() + "&rows=100");

        return res.getContentAsString();
    }

    public String suggestMatchingTerm(String seed) throws Exception {
        String ontologies = "co_320";

        ContentResponse res = olsClient.GET("http://www.ebi.ac.uk/ols/api/suggest?q=" + seed + "&ontology=" + ontologies + "&rows=100");

        return res.getContentAsString();
    }

    private void buildOntologyQueryParam(String name) throws Exception {
        BufferedReader br = new BufferedReader(new FileReader(name));
        String line;

        while ((line = br.readLine()) != null) {
            ontologies.append(line + ",");
        }
        ontologies.deleteCharAt(ontologies.length()-1);
        System.out.println(ontologies.toString());
    }
}