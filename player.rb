require_relative "settings"

class Player

  attr_accessor :pos_x, :pos_y, :snake_or_ladder
  attr_reader :moving

  def initialize(file_image, x, y)
    @image = Gosu::Image.new(file_image, :tileable => true)
    @pos_x = x
    @pos_y = y
    @moving = false
    @destination = []
    @start = 0
    @snake_or_ladder = false
  end

  def width
    @image.width
  end

  def height
    @image.height
  end

  def set_destination(dest)
    @destination.clear
    @destination.push(dest[0], dest[1])
    puts "Destination #{@destination} and position #{@pos_x}, #{@pos_y}"
    @moving = true
  end

  def move
    if !@destination.empty?
      if @moving
        if @pos_y == @destination[1]
          if @pos_x > @destination[0]
            @pos_x = @pos_x - 1
          elsif @pos_x < @destination[0]
            @pos_x = @pos_x + 1
          end

          if @pos_x == @destination[0] && @pos_y == @destination[1]
            @destination.clear
            @start = 0
            @moving = false
            @start = 0
            @first_pos = nil
          end
        end
      end

      if !@destination.empty?
        if @pos_y > @destination[1]
          if @start == 0
            @first_pos = find_row(@pos_y)
            puts "========================="
            puts "y = #{@pos_y}"
            puts "first pos = #{@first_pos}"
            puts "destination y = #{@destination[1]}"
            puts "========================="
            @start = 1
          end

          if @pos_x < @first_pos
            @pos_x += 1
          elsif @pos_x > @first_pos
            @pos_x -= 1
          end

          if @pos_x == @first_pos
            @pos_y -= 1
          end
        end
      end
    end
  end

  def landed
    if @pos_x < @destination[0]
      @pos_x += 1
    elsif @pos_x > @destination[0]
        @pos_x -= 1
    end

    if @pos_y < @destination[1]
      @pos_y += 1
    elsif @pos_y > @destination[1]
      @pos_y -= 1
    end

    if @pos_x == @destination[0] && @pos_y == @destination[1]
      @snake_or_ladder = false
    end
  end

  def update
    if @snake_or_ladder
      landed
    else
      move
    end
  end

  def draw
    @image.draw(@pos_x, @pos_y, 0)
  end

  def find_row(y_pos)
    if y_pos >= Settings::TILE * 9
      x = Settings::TILE * 9
    elsif y_pos >= Settings::TILE * 8
      x = 0
    elsif y_pos >= Settings::TILE * 7
      x = Settings::TILE * 9
    elsif y_pos >= Settings::TILE * 6
      x = 0
    elsif y_pos >= Settings::TILE * 5
      x = Settings::TILE * 9
    elsif y_pos >= Settings::TILE * 4
      x = 0
    elsif y_pos >= Settings::TILE * 3
      x = Settings::TILE * 9
    elsif y_pos >= Settings::TILE * 2
      x = 0
    elsif y_pos >= Settings::TILE
      x = Settings::TILE * 9
    end

    return x
  end

end
