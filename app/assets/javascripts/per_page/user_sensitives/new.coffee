window.UserSensitivesNew =
  user_format: (state)->
    if (!state.id)
      return state.text
    return state.image_path + state.identifier
  init: ->
    user_sensitive_id_field = $("#user_sensitive_user_id")
    user_sensitive_name_field = $("#user_sensitive_name")
    user_sensitive_surname_field = $("#user_sensitive_surname")
    user_sensitive_id_field.select2({
      containerCssClass: "user_auto",
      ajax: {
        url: user_sensitive_id_field.data('fetch-url'),
        data: (term, page)->
          return "term": term
        ,
        results: (data, page)->
          return results: data
      },
      templateResult: @user_format,
      templateSelection: @user_format
    })
    .on('change', (e)->
      el = e.added
      user_sensitive_name_field.val(el.name)
      user_sensitive_surname_field.val(el.surname)
    )

window.UserSensitivesCreate = window.UserSensitivesNew
window.UserSensitivesEdit = window.UserSensitivesNew
window.UserSensitivesUpdate = window.UserSensitivesNew
