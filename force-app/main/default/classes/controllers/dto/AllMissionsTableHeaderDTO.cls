public with sharing class AllMissionsTableHeaderDTO {

    @AuraEnabled
    public String label;
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public String type = 'string';
    @AuraEnabled
    public Boolean sortable = true;

    public AllMissionsTableHeaderDTO(String label, String fieldName) {
        this.label = label;
        this.fieldName = fieldName;
    }
}