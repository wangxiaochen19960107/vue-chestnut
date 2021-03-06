STATIC_PATH = 'images/'
tpl = require '../templates/user-manage.html'
User = Vue.extend {
  template: tpl
  data: () ->
    return {
      add: ''
      selectAll: false
      delShown: false
      addShown: false
      search: ''
      editable: false
      submitData: false
      userList: []
    }
  computed:
    # I want to make sure that userList is pure.so I copy the userList and name it renderList, the new data will be added some descriptive properties.
    renderList: () ->
      result = []
      # give the new user a random default avatar
      avatarArr = ['Lena', 'Lindsay', 'Mark', 'Molly']
      $.each this.userList, (i, item) ->
        clone = $.extend(true, {}, item)
        if $.inArray(item.name, avatarArr) isnt -1
          avatarName = item.name
        else
          index = Math.floor(Math.random() * 3)
          avatarName = avatarArr[index]
        clone.avatar = STATIC_PATH + avatarName + '.png'
        result.push clone
      return result
  watch:
    selectAll: (val) ->
      # update _checked_ key in object _renderList_
      if val
        $.each this.renderList, (i, item) ->
          item.checked = true
          return
      else
        $.each this.userList, (i, item) ->
          item.checked = false
          return
    userList:
      handler: () ->
        # The UI method will be called when data changes
        this.$nextTick () ->
          this.$emit('initListCheckbox')
        return
      deep: true
  methods:
    showCtrl: (type) ->
      if type is 'add'
        this.addShown = !this.addShown
        this.delShown = false
      else if type is 'del'
        this.delShown = !this.delShown
        this.addShown = false
    hideCtrl: () ->
      this.addShown = false
      this.delShown = false
    addUser: () ->
      this.userList.push {
        name: this.add
      }
      this.$broadcast 'eventLine-add', this.add
      this.addShown = false
    delUser: (index) ->
      this.userList.splice(index, 1)
    delSelect: () ->
      self = this
      result = []
      $.each this.renderList, (i, item) ->
        if not item.checked
          # deep clone, cause I need all actions and keys
          clone = $.extend(true, {}, item)
          delete clone.checked
          result.push clone
      this.userList = result
      return
    edit: () ->
      this.editable = !this.editable
  events:
    initListCheckbox: () ->
      self = this
      # Init checkbox UI
      checkboxInList = $('.user-list .ui.checkbox')
      checkboxInList.checkbox {
        onChecked: () ->
          index = $(this).data('index')
          self.renderList[index].checked = true
        onUnchecked: () ->
          index = $(this).data('index')
          self.renderList[index].checked = false
      }
  created: () ->
    self = this
    userListRequest = $.ajax {
      url: '/data/user_list.json'
      dataType: 'json'
    }
    userListRequest.done (data) ->
      self.userList = data.userList
  ready: () ->
    self = this
    this.$emit('initListCheckbox')
    $('.select-all').checkbox {
      onChecked: () ->
        # sync viewmodel
        self.selectAll = true
        # Cause the list will be changed by delete or add
        $('.user-list .ui.checkbox').checkbox('set checked')
        return
      onUnchecked: () ->
        self.selectAll = false
        $('.user-list .ui.checkbox').checkbox('set unchecked')
        return
    }
    return
  components:
    feed: {
      data: () ->
        eventLine: [
        ]
      events:
        add: (name) ->
          date = new Date()
          hour = date.getHours()
          minus = date.getMinutes()
          if /^\d{1}$/.test(minus)
            minus = '0' + minus
          this.eventLine.push {
            time: hour + ':' + minus
            desc: 'add a user named'
            name: name
          }
      created: () ->
        this.$on 'eventLine-add', (name) ->
          this.$emit 'add', name
    }
}
module.exports = User
