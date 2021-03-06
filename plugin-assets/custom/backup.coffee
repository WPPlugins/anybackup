app.controller "BackupController", ($scope, $http, $controller, backupFactory, accountFactory) ->
  $controller("BaseController", {$scope:$scope}) #subclass
  $scope.loading = true
  $scope.list =  ->
    backupFactory.list null, (data) ->
      $scope.backups = data.backups
      $scope.loading = false
      #request.error (data, status, headers, config) =>

  $scope.editName = () ->
    $scope.editingName=true
    focus = ->
      angular.element("#edit-name")[0].focus()
    window.setTimeout focus, 1

  $scope.saveName = () ->
    $scope.editingName=false
    request = $http {
      url: ajaxurl, 
      method: "GET",
      params: {
        action: "bits_backup_update_backup",
        id: $scope.selectedBackup.id
        name: $scope.selectedBackup.name
      }
    }
    request.success (data, status, headers, config) =>
      $scope.list()
      console?.log("Updated name.")

  $scope.backupNow = ->
    $scope.status.backup_running = true
    $scope.backup_cancelled = false
    $scope.backup_loading = true
    $scope.status.step_description = "Starting your backup"
    data = {
        action: "bits_backup_backup_now"
      }
    request = $http {
      url: ajaxurl, 
      method: "POST",
      params: data
    }
    request.success ->
      $scope.updateStatus (data) ->
        $scope.backup_loading = false
      $scope.state = "enabled"

  $scope.supportMessageSent = ->
    $scope.showSupportMessage = true

  $scope.renderBackupOption = (backup) ->
    switch backup.state
      when 'COMMITTED' then (backup.name+' created '+$scope.readableDate(backup))
      when 'CANCELLED' then ('Cancelled: '+backup.name+' created '+$scope.readableDate(backup))
      when 'ERROR' then ('Failed: '+backup.name+' created '+$scope.readableDate(backup))
      else "Invalid backup: "+backup.name


  $scope.showLogs = () ->
    $scope.selectedBackup.showLogs = true

  $scope.hideLogs = () ->
    $scope.selectedBackup.showLogs = false
    
  $scope.updateStatus()
  $scope.statusUpdated = ->
    if($scope.status.most_recent_backup && $scope.status.most_recent_backup.committed_seconds_ago != null && $scope.status.most_recent_backup.committed_seconds_ago < 60)
      # Backup completed.  Refresh list
      $scope.list()

  $scope.status = "Loading"
  $scope.step_number = -1
  $scope.list()

  $scope.$on "user-login", ->
    $scope.updateStatus()
    $scope.list()
  $scope.$on "user-registered", ->
    $scope.thanks_for_registering = true
    $scope.updateStatus()
    $scope.list()
