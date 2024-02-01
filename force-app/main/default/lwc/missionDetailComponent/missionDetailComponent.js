import {LightningElement, wire} from 'lwc';
import acceptMission from '@salesforce/apex/MissionDetailController.acceptMission';
import completeMission from '@salesforce/apex/MissionDetailController.completeMission';
import getMissionDetails from '@salesforce/apex/MissionDetailController.getMissionDetails';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {subscribe, MessageContext} from 'lightning/messageService';
import SAMPLE_MESSAGE_CHANNEL from '@salesforce/messageChannel/SampleMessageChannel__c';
import BUTTON_ACCEPT from '@salesforce/label/c.BUTTON_ACCEPT';
import BUTTON_COMPLETE from '@salesforce/label/c.BUTTON_COMPLETE';
import MISSION_DETAILS_HEADER from '@salesforce/label/c.MISSION_DETAILS_HEADER';
import MISSION_DETAILS_PLACEHOLDER from '@salesforce/label/c.MISSION_DETAILS_PLACEHOLDER';
import ACCEPTED_SUCCESS_TOAST from '@salesforce/label/c.ACCEPTED_SUCCESS_TOAST';
import COMPLETED_SUCCESS_TOAST from '@salesforce/label/c.COMPLETED_SUCCESS_TOAST';

const MISSION_DETAIL_CONFIGURATION = {
    OBJECT_API_NAME: 'Superhero_Mission__c',
    BUTTON_CLASS: {
        SHOW_BUTTON: 'slds-m-top_small',
        HIDE_BUTTON: 'hide-button'
    },
    FIELD_API_NAMES: {
        SUBJECT: 'Subject__c',
        DETAILS: 'Details__c',
        RANK: 'Complexity_Rank__c',
        REWARD: 'Reward__c',
        DEADLINE: 'Deadline__c'
    },
    STATUSES: {
        AVAILABLE: 'Available',
        COMPLETED: 'Completed',
        IN_PROGRESS: 'In Progress',
        FAILED: 'Failed'
    },
    BUTTON_VARIANTS: {
        BRAND: 'brand',
        BRAND_OUTLINE: 'brand-outline'
    },
    TOAST_VARIANTS: {
        SUCCESS: 'success',
        ERROR: 'error',
    }
}

export default class MissionDetail extends LightningElement {
    _selectedMissionId;

    @wire(MessageContext)
    messageContext;

    isLoading = false;
    missionsDetailsHeader = MISSION_DETAILS_HEADER;
    missionsDetailsPlaceholder = MISSION_DETAILS_PLACEHOLDER;
    selectedMissionGuild;
    selectedMissionStatus;
    buttonVariant;
    subjectFieldName;
    detailsFieldName;
    rankFieldName;
    rewardFieldName;
    deadlineFieldName;
    subjectFieldValue;
    detailsFieldValue;
    rankFieldValue;
    rewardFieldValue;
    deadlineFieldValue;
    isLoading = false;

    get buttonLabel () {
        if (this.selectedMissionStatus === MISSION_DETAIL_CONFIGURATION.STATUSES.AVAILABLE) {
            this.buttonVariant = MISSION_DETAIL_CONFIGURATION.BUTTON_VARIANTS.BRAND
            return BUTTON_ACCEPT;
        }

        this.buttonVariant = MISSION_DETAIL_CONFIGURATION.BUTTON_VARIANTS.BRAND_OUTLINE
        return  BUTTON_COMPLETE
    }

    get buttonClassName () {
        if (this.selectedMissionStatus === MISSION_DETAIL_CONFIGURATION.STATUSES.AVAILABLE || this.selectedMissionStatus === MISSION_DETAIL_CONFIGURATION.STATUSES.IN_PROGRESS) {
            return MISSION_DETAIL_CONFIGURATION.BUTTON_CLASS.SHOW_BUTTON;
        }

        return MISSION_DETAIL_CONFIGURATION.BUTTON_CLASS.HIDE_BUTTON;
    }

    get objectApiAName () {
        console.log('MISSION_DETAIL_CONFIGURATION' + MISSION_DETAIL_CONFIGURATION)
        return MISSION_DETAIL_CONFIGURATION.OBJECT_API_NAME;
    }

    get selectedMissionId () {
        return this._selectedMissionId;
    }

    set selectedMissionId (missionId) {
        this._selectedMissionId = missionId;
    }

    _missionData
    get missionData () {
        return this._missionData;
    }

    set missionData (missionData) {
        this._missionData = missionData;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        subscribe(
            this.messageContext,
            SAMPLE_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
    this.isLoading = true;
        this.selectedMissionId = message.Id;
        this.selectedMissionGuild = message.Guild__r.Name;
        this.selectedMissionStatus = message.Status;
        getMissionDetails({ missionId: message.Id })
            .then( missionDetails => {
                this.subjectFieldName = missionDetails.subjectFieldLabel;
                this.detailsFieldName = missionDetails.detailsFieldLabel;
                this.rankFieldName = missionDetails.rankFieldLabel;
                this.rewardFieldName = missionDetails.rewardFieldLabel;
                this.deadlineFieldName = missionDetails.deadlineFieldLabel;

                this.subjectFieldValue = missionDetails.record.Subject__c;
                this.detailsFieldValue = missionDetails.record.Details__c;
                this.rankFieldValue = missionDetails.record.Complexity_Rank__c;
                this.rewardFieldValue = missionDetails.record.Reward__c;
                this.deadlineFieldValue = missionDetails.record.Deadline__c;

                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.showToastEvent(
                    error.body.message,
                    MISSION_DETAIL_CONFIGURATION.TOAST_VARIANTS.ERROR
                );
        })
    }

    handleButtonClick() {
        console.log('1')
        if (this.selectedMissionStatus === MISSION_DETAIL_CONFIGURATION.STATUSES.AVAILABLE) {
            acceptMission({ missionId: this.selectedMissionId })
                .then(() => {
                    this.showToastEvent(
                        ACCEPTED_SUCCESS_TOAST,
                        MISSION_DETAIL_CONFIGURATION.TOAST_VARIANTS.SUCCESS
                    );
                }).catch(error => {
                    this.showToastEvent(
                        error.body.message,
                        MISSION_DETAIL_CONFIGURATION.TOAST_VARIANTS.ERROR
                    );
                })
        } else if (this.selectedMissionStatus === MISSION_DETAIL_CONFIGURATION.STATUSES.IN_PROGRESS) {
            completeMission({ missionId: this.selectedMissionId })
                .then(() => {
                    this.showToastEvent(
                        COMPLETED_SUCCESS_TOAST,
                        MISSION_DETAIL_CONFIGURATION.TOAST_VARIANTS.SUCCESS
                    );
                }).catch(error => {
                    this.showToastEvent(
                        error.body.message,
                        MISSION_DETAIL_CONFIGURATION.TOAST_VARIANTS.ERROR
                    );
                });
        }
    }

    showToastEvent(title, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant
            })
        );
    }
}