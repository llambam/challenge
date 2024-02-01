({
    constants: {
      statuses: {
          IN_PROGRESS: 'In Progress',
          FAILED: 'Failed',
          AVAILABLE: 'Available',
          COMPLETED: 'Completed'
      }
    },

    setStatuses: function(cmp) {
        cmp.set("v.failedStatus", this.constants.statuses.FAILED);
        cmp.set("v.availableStatus", this.constants.statuses.AVAILABLE);
        cmp.set("v.inProgressStatus", this.constants.statuses.IN_PROGRESS);
        cmp.set("v.completedStatus", this.constants.statuses.COMPLETED);
    },

    fetchMissions: function(cmp) {
        let action = cmp.get("c.getMissions");
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue().data;
                data.forEach(row => row.GuildName = row.Guild__r.Name)
                cmp.set('v.columns', response.getReturnValue().columns);
                cmp.set("v.missions", data);
            } else {
                console.error("Error fetching missions: " + state);
                console.log(JSON.stringify(state));
            }
        });
        $A.enqueueAction(action);
    },

    publishDataOnMessageChannel: function (cmp, event) {
        const missions = cmp.get("v.missions");
        const missionId = event.currentTarget.dataset.missionId;
        let selectedMission = missions.find((mission) => mission.Id === missionId);

        console.log(selectedMission);
        cmp.find("sampleMessageChannel").publish(selectedMission);
    }
})