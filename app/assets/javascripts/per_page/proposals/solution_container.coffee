class Airesis.SolutionContainer
  @selector: '.solution_main'
  constructor: (@id)->
    if @id instanceof jQuery
      @element = @id
      @id = @element.data('solution_id')
    else
      @element = $(Airesis.SolutionContainer.selector).filter("[data-solution_id='#{@id}']")
    @destroyField = @element.find("[data-solution-destroy]")
    @seqField = @element.find("[name='proposal[solutions_attributes][#{@id}][seq]']")
    @titleField = @element.find("[name$='proposal[solutions_attributes][#{@id}][title]']")
    @sections = @element.find(Airesis.SectionContainer.selector)
  persisted: ->
    @element.data('persisted')
  moveUp: ->
    to_exchange = @element.prevAll(Airesis.SolutionContainer.selector).first()
    @element.after to_exchange
    ProposalsEdit.updateSolutionSequences()
  moveDown: ->
    to_exchange = @element.nextAll(Airesis.SolutionContainer.selector).first()
    @element.before to_exchange
    ProposalsEdit.updateSolutionSequences()
  remove: ->
    if confirm Airesis.i18n.proposals.edit.removeSolutionConfirm
      if @persisted
        @destroyField.val(1)
        @element.fadeOut()
      else
        @element.fadeOut ->
          @element.remove()
      @element.nextUntil(null, Airesis.SolutionContainer.selector).each ->
        sol_id = $(this).attr('data-solution_id')
        id = $(this).find('textarea').attr('id')
        seqel_ = $('[name^=\'proposal[solutions_attributes][' + sol_id + '][seq]\']')
        seq_ = parseInt(seqel_.val())
        $(this).find('.title_placeholder .num').html seq_ - 1
      ProposalsEdit.fakeSolutionsCount--
      return true
      ProposalsEdit.updateSolutionSequences()
    else
      return false
  setSeq: (val)->
    @seqField.val(val)
  isCompressed: ->
    @element.data('compressed') is true
  toggle: (compress) ->
    if @element.is(':animated')
      return false
    if compress
      @hide()
    else
      @show()
  show: ->
    duration = 500
    easing = 'swing'
    if @element.is(':animated')
      return false
    if @isCompressed()
      @element.data('compressed', false)
      @element.animate { 'height': @element.attr('data-height') }, duration, easing, ->
      @element.find('.sol_content').show()
  hide: ->
    duration = 500
    easing = 'swing'
    toggleMinHeight = 100
    if @element.is(':animated')
      return false
    if !@isCompressed()
      @element.data('compressed', true)
      @element.attr 'data-height', @element.height()
      @element.find('.sol_content').hide()
      @element.animate { 'height': toggleMinHeight }, duration, easing, ->
