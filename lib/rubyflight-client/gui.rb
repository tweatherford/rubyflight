include Fox

class ShutterItem < FXShutterItem
  def initialize(p, text, icon = nil, opts = 0)
    super(p, text, icon, opts | LAYOUT_FILL_X | LAYOUT_TOP | LAYOUT_LEFT, :padding => 10, :hSpacing => 10, :vSpacing => 10)
    button.padTop = 2
    button.padBottom = 2
  end
end

class ShutterButton < FXButton
  def initialize(p, txt, ic = nil)
    super(p, txt, ic, :opts => BUTTON_TOOLBAR | TEXT_BELOW_ICON | FRAME_THICK | FRAME_RAISED | LAYOUT_FILL_X | LAYOUT_TOP | LAYOUT_LEFT)
    self.backColor = p.backColor
    self.textColor = FXRGB(255, 255, 255)
  end
end

class Window < FXMainWindow
  attr_reader :switcher_widgets
  attr_reader :statusbar
  
  def initialize(app)
    super(app, "FS Operations", :width => 800, :height => 400)
    app.main_window = self

    # Status bar along the bottom
    @statusbar = FXStatusBar.new(self, LAYOUT_SIDE_BOTTOM | LAYOUT_FILL_X | STATUSBAR_WITH_DRAGCORNER)

    # Main contents area is split left-to-right
    splitter = FXSplitter.new(self, (LAYOUT_SIDE_TOP | LAYOUT_FILL_X | LAYOUT_FILL_Y | SPLITTER_TRACKING))

    # Shutter area on the left
    @shutter = FXShutter.new(splitter, :opts => FRAME_SUNKEN | LAYOUT_FILL_X | LAYOUT_FILL_Y,
      :padding => 0, :hSpacing => 0, :vSpacing => 0)

    # Switcher on the right
    switcher = FXSwitcher.new(splitter, FRAME_SUNKEN | LAYOUT_FILL_X | LAYOUT_FILL_Y, :padding => 0)

    # Shutter buttons
    shutter_item = ShutterItem.new(@shutter, "Sections", nil, LAYOUT_FILL_Y)
    ShutterButton.new(shutter_item.content, "Flight\nStatus").connect(SEL_COMMAND) { switcher.current = 0 }
    #ShutterButton.new(shutter_item.content, "Airport\nOperations").connect(SEL_COMMAND) { switcher.current = 1 }
    #ShutterButton.new(shutter_item.content, "Aircrafts").connect(SEL_COMMAND) { @switcher.current = 2 }
    #ShutterButton.new(shutter_item.content, "Debug").connect(SEL_COMMAND) { @switcher.current = 3 }

    @switcher_widgets = Hash.new {|h,k| h[k]={} }

    #------------ Flight status -------------#
    frame = FXVerticalFrame.new(switcher)

    matrix = FXMatrix.new(frame, 2, MATRIX_BY_COLUMNS | LAYOUT_CENTER_X)

    FXLabel.new(matrix, "Aircraft:", nil, LAYOUT_SIDE_RIGHT | LAYOUT_FILL_X)
    @switcher_widgets[:flight][:aircraft] = FXLabel.new(matrix, "", nil, LAYOUT_SIDE_LEFT | LAYOUT_FILL_X)
    FXLabel.new(matrix, "Status:", nil, LAYOUT_SIDE_RIGHT | LAYOUT_FILL_X)
    @switcher_widgets[:flight][:status] = FXLabel.new(matrix, "", nil, LAYOUT_SIDE_LEFT | LAYOUT_FILL_X)
    FXLabel.new(matrix, "Location:", nil, LAYOUT_SIDE_RIGHT | LAYOUT_FILL_X)
    @switcher_widgets[:flight][:location] = FXLabel.new(matrix, "", nil, LAYOUT_SIDE_LEFT | LAYOUT_FILL_X)
#    FXLabel.new(matrix, "Condition:", nil, LAYOUT_SIDE_RIGHT | LAYOUT_FILL_X)
#    switcher_widgets[:flight][:condition] = FXLabel.new(matrix, "?", nil, LAYOUT_SIDE_LEFT | LAYOUT_FILL_X)

    start_button = FXButton.new(frame, 'Start Flight', nil, nil, 0, FRAME_RAISED | LAYOUT_CENTER_X, :padLeft => 10, :padRight => 10)
    font = start_button.font.fontDesc; font.size += 35
    start_button.font = FXFont.new(app, font)
    start_button.disable
    @switcher_widgets[:flight][:start_button] = start_button

    #--------- Airport Operations ----------#
#    frame = FXVerticalFrame.new(switcher)
#
#    FXLabel.new(frame, "Available at airport (insert destination ICAO)")
#    @switcher_widgets[:airport][:destination] = FXTextField.new(frame, 5)
#    @switcher_widgets[:airport][:accept_destination] = FXButton.new(frame, "Get")
#    table1 = FXTable.new(frame, nil, 0, TABLE_NO_COLSELECT | TABLE_READONLY | LAYOUT_FILL_X | LAYOUT_FILL_Y)
#    table1.appendColumns(2)
#    table1.setColumnText(0, "Cargo Name")
#    table1.setColumnText(1, "Weight")
#    table1.rowHeaderMode = LAYOUT_FIX_WIDTH
#    table1.rowHeaderWidth = 0
#    @switcher_widgets[:airport][:available_cargo] = table1
#
#    FXButton.new(frame, 'Transfer', nil, nil, 0, BUTTON_NORMAL | LAYOUT_CENTER_X)
#
#    FXLabel.new(frame, "Available on aircraft")
#    table2 = FXTable.new(frame, nil, 0, TABLE_NO_COLSELECT | TABLE_READONLY | LAYOUT_FILL_X | LAYOUT_FILL_Y)
#    table2.appendColumns(3)
#    table2.setColumnText(0, "Cargo Name")
#    table2.setColumnText(1, "Weight")
#    table2.setColumnText(2, "Destination")
#    table2.rowHeaderMode = LAYOUT_FIX_WIDTH
#    table2.rowHeaderWidth = 0
#    @switcher_widgets[:airport][:loaded_cargo] = table2
  end

  def create
    super
    @shutter.width *= 1.6
    show(PLACEMENT_SCREEN)
  end
end

class Application < FXApp
  attr_accessor :main_window

  include GuiLogic

  def self.run
    app = Application.new
    Window.new(app)
    app.create
    app.run_loop
  end
end