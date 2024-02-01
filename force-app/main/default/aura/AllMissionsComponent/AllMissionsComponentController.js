({
    doInit: function(cmp, event, helper) {
        helper.setStatuses(cmp);
        helper.fetchMissions(cmp);
    },

    handleMissionClick: function(cmp, event, helper) {
        helper.publishDataOnMessageChannel(cmp, event)
    }
})