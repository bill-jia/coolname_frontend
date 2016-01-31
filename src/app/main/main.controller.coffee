app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "Restangular", "$mdDialog", "$mdMedia", "$mdToast"
    ($scope, $timeout, Restangular, $mdDialog, $mdMedia, $mdToast) ->

      $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
      $scope.words = [{word: "Potato", definition: "The best vegetable"}, {word: "Broccoli", definition: "The worst vegetable"}]
      $scope.direction = "left"
      console.log "Main controller engaged"
      $scope.currIndex = 0
      maxWords = 2
      user = {username: "TheUser", id: ""}
      $scope.word = $scope.words[$scope.currIndex]
  		
      Restangular.all("related").all("all").getList().then((words) ->
        $scope.words = words
        maxWords = $scope.words.length
        console.log maxWords
        console.dir $scope.words
        $scope.word = words[$scope.currIndex]
      )

      $scope.isCurrentIndex = (index) ->
        index is $scope.currIndex

      $scope.addWord = (word) ->
        # POST word to words
        Restangular.all("words").post(word)
        Restangular.all("related").post(word).then((words) ->
          maxWords = $scope.words.length
          $scope.currIndex = 0
          $scope.words = words
          $scope.word = words[$scope.currIndex]
        )
      
      $scope.saveWord = () ->
        # POST word to words
        Restangular.all("words").post($scope.word)
        $scope.direction = "right"
        $scope.currIndex++
        console.log $scope.currIndex
        if $scope.currIndex > maxWords-1
          maxWords = $scope.words.length
          $scope.currIndex = 0
          Restangular.all("related").all("all").getList().then((words) ->
            console.log "Words reloaded"
            maxWords = $scope.words.length
            $scope.currIndex = 0
            $scope.words = words
            $scope.word = words[$scope.currIndex]
          )
        else        
          $scope.word = $scope.words[$scope.currIndex]
        console.log "Word saved"
        $mdToast.show({
          controller: ""
          templateUrl: "app/main/toast.html"
          template: "Word Added!"
          hideDelay: 2000
          position: "top right"          
        })
             

      $scope.removeWord = () ->
        $scope.direction = "left"
        $scope.currIndex++
        console.log $scope.currIndex
        if $scope.currIndex > maxWords-1
          maxWords = $scope.words.length
          $scope.currIndex = 0
          Restangular.all("related").all("all").getList().then((words) ->
            console.log "Words reloaded"
            maxWords = $scope.words.length            
            $scope.currIndex = 0
            $scope.words = words
            $scope.word = $scope.words[$scope.currIndex]
          )
        else      
          $scope.word = $scope.words[$scope.currIndex]
        console.log "Word rejected"

      $scope.openDef = (ev) ->
        useFullScreen = ($mdMedia('sm') || $mdMedia('xs')) && $scope.customFullscreen

        $mdDialog.show({
          controller: DialogController
          templateUrl: "app/main/definition.html"
          parent: angular.element(document.body)
          targetEvent: ev
          clickOutsideToClose: true
          fullscreen: useFullScreen
          locals: {
            name: $scope.word.name
            definition: $scope.word.definition
          }
        })

      $scope.openInput = (ev) ->
        useFullScreen = ($mdMedia('sm') || $mdMedia('xs')) && $scope.customFullscreen
        
        $mdDialog.show({
          controller: InputDialogController
          templateUrl: "app/main/inputword.html"
          parent: angular.element(document.body)
          targetEvent: ev
          clickOutsideToClose: true
          fullscreen: useFullScreen
        }).then(
          (word) ->
            console.log word
            $scope.addWord(word)
          () ->
            console.log "dialog closed"
        )
])

app.animation(".slide-animation", ["$window", ($window) ->
  load: (element, done) ->
    scope = element.scope()
    TweenMax.to(element, 1, {opacity:1})

  beforeAddClass: (element, className, done) ->
    scope = element.scope()

    if className == 'ng-hide'
      console.log scope.direction
      finishPoint = element.parent().width()
      if scope.direction is 'left'
        console.log "reverse finish"
        finishPoint = -finishPoint
      console.log finishPoint
      TweenMax.to(element, 1, {left: finishPoint, onComplete: done, opacity:0 })
    else
      done()
    return
  removeClass: (element, className, done) ->
    scope = element.scope()

    if className == 'ng-hide'
      element.removeClass 'ng-hide'
      console.log scope.direction
      startPoint = element.parent().width()
      if scope.direction is 'right'
        console.log "reverse start"
        startPoint = -startPoint
      console.log startPoint

      TweenMax.set(element, { left: startPoint })
      currAnimation = TweenMax.to(element, 1, {left: 0, onComplete: done, opacity:1})
      console.log currAnimation.delay()
    else
      done()
    return
])


DialogController = ["$scope", "$mdDialog", "name", "definition",
  ($scope, $mdDialog, name, definition) ->
    $scope.name = name
    $scope.definition = definition

    $scope.hide = () ->
      $mdDialog.hide()

]

InputDialogController = ["$scope", "$mdDialog",
  ($scope, $mdDialog) ->
    $scope.word =""
    $scope.cancel = () ->
      console.log "Cancel clicked"
      $mdDialog.cancel()
    $scope.answer = () ->
      $mdDialog.hide($scope.word)
    $scope.hide = () ->
      $mdDialog.hide()

]