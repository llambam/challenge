import {api, LightningElement, wire} from 'lwc';
import acceptMission from '@salesforce/apex/MissionDetailController.acceptMission';
import completeMission from '@salesforce/apex/MissionDetailController.completeMission';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {subscribe, MessageContext} from 'lightning/messageService';
import SAMPLE_MESSAGE_CHANNEL from '@salesforce/messageChannel/SampleMessageChannel__c';
import BUTTON_ACCEPT from '@salesforce/label/c.BUTTON_ACCEPT';
import BUTTON_COMPLETE from '@salesforce/label/c.BUTTON_COMPLETE';
import MISSION_DETAILS_HEADER from '@salesforce/label/c.MISSION_DETAILS_HEADER';
import MISSION_DETAILS_PLACEHOLDER from '@salesforce/label/c.MISSION_DETAILS_PLACEHOLDER';


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

    get subjectFieldApiAName () {
        return MISSION_DETAIL_CONFIGURATION.FIELD_API_NAMES.SUBJECT;
    }

    get detailsFieldApiAName () {
        return MISSION_DETAIL_CONFIGURATION.FIELD_API_NAMES.DETAILS;
    }

    get rankFieldApiAName () {
        return MISSION_DETAIL_CONFIGURATION.FIELD_API_NAMES.RANK;
    }

    get rewardFieldApiAName () {
        return MISSION_DETAIL_CONFIGURATION.FIELD_API_NAMES.REWARD;
    }

    get deadlineFieldApiAName () {
        return MISSION_DETAIL_CONFIGURATION.FIELD_API_NAMES.DEADLINE;
    }

    get selectedMissionId () {
        return this._selectedMissionId;
    }

    set selectedMissionId (missionId) {
        this._selectedMissionId = missionId;
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
        if (message.hasOwnProperty('Id')) {
            this.selectedMissionId = message.Id;
            this.selectedMissionGuild = message.Guild__r.Name;
            this.selectedMissionStatus = message.Status__c;
            this.selectedMissionRank = message.Complexity_Rank__c;
            this.reInitAllMissionsComponent = message.reInitAllMissionsComponent;
            this.isLoading = false;
        }
    }

    handleButtonClick() {
        console.log('1')
        if (this.selectedMissionStatus === MISSION_DETAIL_CONFIGURATION.STATUSES.AVAILABLE) {
            acceptMission({ missionId: this.selectedMissionId })
                .then(() => {
                    this.showToastEvent(
                        'Mission accepted successfully.',
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
                        'Mission completed successfully.',
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