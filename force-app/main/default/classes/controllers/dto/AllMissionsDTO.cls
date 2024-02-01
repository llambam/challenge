public with sharing class AllMissionsDTO {

    @AuraEnabled
    public List<AllMissionsTableHeaderDTO> columns;
    @AuraEnabled
    public List<Superhero_Mission__c> data;

    public AllMissionsDTO (List<AllMissionsTableHeaderDTO> columns, List<Superhero_Mission__c> data) {
        this.columns = columns;
        this.data = data;
    }

}