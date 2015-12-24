@VecheSCA ?= {}

@VecheSCA.SCASoundChangeGroup = React.createClass
  getInitialState: ->
    decomposed: []
    isShowingDecomposed: []

  componentWillMount: ->
    VecheSCA.Event.register 'api:soundChange:response', @setDecomposedSoundChange
    VecheSCA.Event.register 'api:rules:response', @clearDecomposed

  render: ->
    title = @props.group.title
    description = @props.group.description
    soundChanges = @renderSoundChanges()
    editButton = @renderEditButton()
    `<li className="sound-change-group">
       {editButton}
       <div className="sound-change-group-inner">
         <h3>{title}</h3>
         <p className="description">{description}</p>
         {soundChanges}
       </div>
     </li>
    `

  renderSoundChanges: ->
    for soundChange, idx in (@props.group.sound_changes ? [])
      active = @state.isShowingDecomposed[idx]
      toggleDecomposed = @toggleDecomposed.bind(@, soundChange.order)
      decomposed = @renderDecomposed(soundChange.order)
      className = Utils.classSet("sound-change", "decomposed" if active)
      rule = @renderSingleRule(soundChange)
      `<div className={className} key={soundChange.order}>
         <button className="fa toggle-decomposed"
                 data-active={active}
                 onClick={toggleDecomposed}></button>
         <div className="primary">
           {rule}
         </div>
         {decomposed}
       </div>
      `

  renderSingleRule: (soundChange) ->
    if soundChange.environment is "_"
      # Don't render the environment if it is global
      "#{soundChange.input} → #{soundChange.output}"
    else
      "#{soundChange.input} → #{soundChange.output} / #{soundChange.environment}"

  renderDecomposed: (order) ->
    return null unless @state.isShowingDecomposed[order - 1]
    decomposed = @state.decomposed[order - 1]
    if decomposed
      decomposedElements = (`<li>{formula}</li>` for formula in decomposed)
      `<ul className="decomposed">
         {decomposedElements}
       </ul>
      `
    else
      `<div className="decomposed">Loading...</div>`

  renderEditButton: ->
    if @props.editable
      editGroup = @editGroup
      `<button onClick={editGroup} className="fa fa-edit"></button>`

  editGroup: ->
    VecheSCA.API.getRule(@props.group.order)

  toggleDecomposed: (order, evt) ->
    evt.preventDefault()
    isShowingDecomposed = @state.isShowingDecomposed
    isShowingDecomposed[order - 1] = !isShowingDecomposed[order - 1]
    @setState(isShowingDecomposed: isShowingDecomposed)
    unless @state.decomposed[order - 1]
      VecheSCA.API.getDecomposedSoundChange(@props.group.order, order)

  setDecomposedSoundChange: (data) ->
    if @props.group.order == data.ruleOrder
      decomposed = @state.decomposed
      decomposed[data.changeOrder - 1] = data
      @setState(decomposed: decomposed)

  clearDecomposed: ->
    if @props.group.sound_changes
      @setState
        decomposed: null for soundChange in @props.group.sound_changes
        isShowingDecomposed: false for soundChange in @props.group.sound_changes
    else
      @setState(decomposed: [], isShowingDecomposed: [])
