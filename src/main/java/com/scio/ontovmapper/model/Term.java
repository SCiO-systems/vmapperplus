package com.scio.ontovmapper.model;

public class Term {
    private String type;
    private String id;
    private String iri;
    private String shortForm;
    private String oboId;
    private String label;
    private String ontologyName;
    private String ontologyPrefix;

    public Term(String type, String id, String iri, String shortForm, String oboId, String label, String ontologyName, String ontologyPrefix) {
        this.type = type;
        this.id = id;
        this.iri = iri;
        this.shortForm = shortForm;
        this.oboId = oboId;
        this.label = label;
        this.ontologyName = ontologyName;
        this.ontologyPrefix = ontologyPrefix;
    }

    public Term(String iri, String label, String id) {
        this.iri = iri;
        this.label = label;
        this.id = id;
        this.oboId = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIri() {
        return iri;
    }

    public void setIri(String iri) {
        this.iri = iri;
    }

    public String getShortForm() {
        return shortForm;
    }

    public void setShortForm(String shortForm) {
        this.shortForm = shortForm;
    }

    public String getOboId() {
        return oboId;
    }

    public void setOboId(String oboId) {
        this.oboId = oboId;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getOntologyName() {
        return ontologyName;
    }

    public void setOntologyName(String ontologyName) {
        this.ontologyName = ontologyName;
    }

    public String getOntologyPrefix() {
        return ontologyPrefix;
    }

    public void setOntologyPrefix(String ontologyPrefix) {
        this.ontologyPrefix = ontologyPrefix;
    }
}
