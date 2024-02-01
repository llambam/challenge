public with sharing class MissionDetailDTO {

    @AuraEnabled
    public String subjectFieldLabel;
    @AuraEnabled
    public String detailsFieldLabel;
    @AuraEnabled
    public String rankFieldLabel;
    @AuraEnabled
    public String rewardFieldLabel;
    @AuraEnabled
    public String deadlineFieldLabel;
    @AuraEnabled
    public Superhero_Mission__c record;

    public MissionDetailDTO(String subjectFieldLabel, String detailsFieldLabel, String rankFieldLabel, String rewardFieldLabel, String deadlineFieldLabel, Superhero_Mission__c record) {
        this.subjectFieldLabel = subjectFieldLabel;
        this.detailsFieldLabel = detailsFieldLabel;
        this.rankFieldLabel = rankFieldLabel;
        this.rewardFieldLabel = rewardFieldLabel;
        this.deadlineFieldLabel = deadlineFieldLabel;
        this.record = record;
    }


}