# This code is used to improve the window to wall ratio. It now allows the user to specify the number of windows per surface in addition to the window's height/width

class WWRScriptModified < OpenStudio::Ruleset::ModelUserScript
  
  # override name to return the name of your script
  def name
    return "Set Individual Windows"
  end

# ------------------------------------------------------------------------------------------ #
  # returns a vector of arguments, the runner will present these arguments to the user
  # then pass in the results on run
  def arguments(model)
    result=OpenStudio::Ruleset::OSArgumentVector.new

  # Setting up the pop up menu 

    # window to wall ratio
    wwr = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("wwr",false)
    wwr.setDisplayName("Window to Wall Ratio (fraction)")
    wwr.setDefaultValue(0.20)
    result << wwr

    # offset value 
    offset = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("offset",false)
    offset.setDisplayName("Offset (meters)")
    offset.setDefaultValue(1.0)
    result << offset

    # application type
    choices = OpenStudio::StringVector.new
    choices << "Above Floor"
    choices << "Below Ceiling"
    application_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("application_type", choices,false)
    application_type.setDisplayName("Application Type")
    application_type.setDefaultValue("Above Floor")
    result << application_type

    # number of windows
    number_of_windows = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("number_of_windows",false)
    number_of_windows.setDisplayName("Number of Windows (#)")
    number_of_windows.setDefaultValue(2)
    result << number_of_windows

    # width of window
    width_of_window = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("width_of_window",false)
    width_of_window.setDisplayName("Width of Window (meters)")
    width_of_window.setDefaultValue(3)
    result << width_of_window

    # height of window
    height_of_window = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("height_of_window",false)
    height_of_window.setDisplayName("Height of Window (meters)")
    height_of_window.setDefaultValue(3)
    result << height_of_window

    return result
  end # End argument def
# ------------------------------------------------------------------------------------------ #

  # override run to implement the functionality of your script
  # model is an OpenStudio::Model::Model, runner is a OpenStudio::Ruleset::UserScriptRunner
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments) # initializes runner for new script

    if not runner.validateUserArguments(arguments(model),user_arguments)
      return false
    end

    wwr = runner.getDoubleArgumentValue("wwr",user_arguments)
    offset = runner.getDoubleArgumentValue("offset",user_arguments)
    application_type = runner.getStringArgumentValue("application_type",user_arguments)
    number_of_windows = runner.getDoubleArgumentValue("number_of_windows",user_arguments)
    width_of_window = runner.getDoubleArgumentValue("width_of_window",user_arguments)
    height_of_window = runner.getDoubleArgumentValue("height_of_window",user_arguments)

    
    # input error checking 
    if not wwr or not offset or not application_type or not  number_of_windows
      runner.registerError("You are missing needed information.")
      return false
    end
    
    if wwr <= 0 or wwr >= 1
      runner.registerError("The Window to Wall Ratio must be greater than 0 and less than 1.")
      return false
    end
    
    if offset <= 0
      runner.registerError("Offset value must be greater than 0.")
      return false
    end
  
    if number_of_windows <= 0
      runner.registerError("The number of windows must be greater than 0.")
      return false
    end  
    
    # Customize window size
    # Model code for inputting and modifying windows and surfaces


      
    # Customize window size
    any_in_selection = false



    model.getSurfaces.each do |s|

    #runner.registerAsNotApplicable("#{s}")      

      next if not runner.inSelection(s)
      any_in_selection = true

      next if not s.outsideBoundaryCondition == "Outdoors"
      next if not s.surfaceType == "Wall"

      # puts s.outsideBoundaryCondition   # for debug
      surface_name=s.name.to_s          # get surface name    
      # puts surface_name.class

      #runner.registerAsNotApplicable("#{surface_name}")

      # Defines a vertices_array that is going to be used to create the window
      vertices_array = []         # contains four vertices
      s.vertices.each do |v|
        vertices_array << v
      end

      # calculate center of window vertices
      sum_x=0
      sum_y=0
      sum_z=0
    
      vertices_array.each do |v|
        sum_x = sum_x + v.x
        sum_y = sum_y + v.y
        sum_z = sum_z + v.z
      end
               
      cx = (sum_x/4).to_f
      cy = (sum_y/4).to_f
      cz = (sum_z/4).to_f
                
      len_1 = Math.sqrt( (vertices_array[0].x-vertices_array[1].x)**2+(vertices_array[0].y-vertices_array[1].y)**2+(vertices_array[0].z-vertices_array[1].z)**2 )
      len_2 = Math.sqrt( (vertices_array[0].x-vertices_array[2].x)**2+(vertices_array[0].y-vertices_array[2].y)**2+(vertices_array[0].z-vertices_array[2].z)**2 )
      len_3 = Math.sqrt( (vertices_array[0].x-vertices_array[3].x)**2+(vertices_array[0].y-vertices_array[3].y)**2+(vertices_array[0].z-vertices_array[3].z)**2 )

      
      diagonal = [len_1, len_2, len_3].max
      width = [len_1, len_2, len_3].min
      length = len_1+len_2+len_3 - diagonal - width

      runner.registerAsNotApplicable("what is the diagonal length #{diagonal}")
      runner.registerAsNotApplicable("what is the width #{width}")
      runner.registerAsNotApplicable("what is the length #{length}")
     
# This portion was slightly modfied from the original run code. In that code 3/2=1 just as ruby should do. However, here we get 3/2=1.5. Therefore, we needed to account for the extra 0.5.
       
          j = (number_of_windows/2)-0.5
          k = 1
          l = (number_of_windows/2)-0.5
          m = 0.5

         
# ------------------------------------------------------------------------------------------ #
  # Loop through the number of windows on each surface
          
      for i in (1..number_of_windows)
        window_polygon_i = OpenStudio::Point3dVector.new

        # Setting the center vertex for the window for odd number of windows 
        if number_of_windows%2 != 0
          if j >= 0
            cx_i = cx - j * (length/number_of_windows)
            cy_i = cy - j * (length/number_of_windows)
            j = j-1
          else
            cx_i = cx + k * (length/number_of_windows)
            cy_i = cy + k * (length/number_of_windows)
            k = k+1
          end 
  
        # Setting the center vertex for the window for even number of windows  
        else
  
          if l > 0
            cx_i = cx - l * (length/number_of_windows)
            cy_i = cy - l * (length/number_of_windows)
            l = l-1
             
          else
            cx_i = cx + m * (length/number_of_windows)
            cy_i = cy + m * (length/number_of_windows)
            m = m+1
          end
        end   
# ------------------------------------------------------------------------------------------ #
# Setting the co-ordinates of all the four vertices of a window

        if vertices_array[0].x == vertices_array[1].x and vertices_array[1].x == vertices_array[2].x and vertices_array[2].x == vertices_array[3].x 
          upleft_point_i = OpenStudio::Point3d.new(cx, cy_i-0.5*(width_of_window), cz+0.5*height_of_window)
          upright_point_i = OpenStudio::Point3d.new(cx, cy_i+0.5*(width_of_window), cz+0.5*height_of_window)
          downleft_point_i = OpenStudio::Point3d.new(cx, cy_i-0.5*(width_of_window), cz-0.5*height_of_window)
          downright_point_i = OpenStudio::Point3d.new(cx, cy_i+0.5*(width_of_window), cz-0.5*height_of_window)
        else
          upleft_point_i = OpenStudio::Point3d.new(cx_i-0.5*(width_of_window), cy, cz+0.5*height_of_window)
          upright_point_i = OpenStudio::Point3d.new(cx_i+0.5*(width_of_window), cy, cz+0.5*height_of_window)
          downleft_point_i = OpenStudio::Point3d.new(cx_i-0.5*(width_of_window), cy, cz-0.5*height_of_window)
          downright_point_i = OpenStudio::Point3d.new(cx_i+0.5*(width_of_window), cy, cz-0.5*height_of_window) 
        end
# ------------------------------------------------------------------------------------------ #
#   get the absoluteAzimuth for the surface so we can categorize it

        absoluteAzimuth=model.getBuilding.northAxis
        building_name = model.getBuilding.name
        absoluteAzimuth =  OpenStudio::convert(s.azimuth,"rad","deg").get + s.space.get.directionofRelativeNorth + model.getBuilding.northAxis
            
        until absoluteAzimuth < 360.0
          absoluteAzimuth = absoluteAzimuth - 360.0
        end
          
        # for the surface aligned in north direction    
  
        if (absoluteAzimuth >= 315.0 or absoluteAzimuth < 45.0)
          window_polygon_i << upleft_point_i
          window_polygon_i << upright_point_i
          window_polygon_i << downright_point_i
          window_polygon_i << downleft_point_i
                    
        # for the surface aligned in east direction         
        elsif (absoluteAzimuth >= 45.0 and absoluteAzimuth < 135.0)
          window_polygon_i << upright_point_i
          window_polygon_i << upleft_point_i
          window_polygon_i << downleft_point_i
          window_polygon_i << downright_point_i
                
         # for the surface aligned in south direction                
        elsif (absoluteAzimuth >= 135.0 and absoluteAzimuth < 225.0)
          window_polygon_i << upright_point_i
          window_polygon_i << upleft_point_i
          window_polygon_i << downleft_point_i
          window_polygon_i << downright_point_i
                
        # for the surface aligned in west direction               
        elsif (absoluteAzimuth >= 225.0 and absoluteAzimuth < 315.0)
          window_polygon_i << upleft_point_i
          window_polygon_i << upright_point_i
          window_polygon_i << downright_point_i
          window_polygon_i << downleft_point_i
              
        else
          return false
        end
            
# ------------------------------------------------------------------------------------------ #
# Now to draw the surfaces
        sub_surface = OpenStudio::Model::SubSurface.new(window_polygon_i, model)
        sub_surface.setSurface(s)
        sub_surface.setSubSurfaceType("FixedWindow")    

        #   End of For loop for all the windows   
      end


   #  End of loop through each surface 
   #end
# End of window customization #
  #end


#end

=begin
    if new_window.empty?
      ok = runner.registerWarning("Unable to set window-to-wall ratio of " + s.name.get + " to " + wwr.to_s + ".")
    else
  # not fully accurate - Dan to refactor wiggliness out of C++
      actual = new_window.get.grossArea / s.grossArea
      runner.registerInfo("Set window-to-wall ratio of " + s.name.get + " to " + actual.to_s + ".")
      if not (OpenStudio::DoublesRelativeError(wwr,actual) < 1.0E-3)
        ok = runner.registerInfo("Tried to set window-to-wall ratio of " + s.name.get + " to " + 
                                   wwr.to_s + ", but set to " + actual.to_s + " instead.")
      end
    end
=end    
    end

  
    if not any_in_selection
      runner.registerAsNotApplicable("No surfaces in the current selection.  Please select surfaces or spaces to set Window to Wall Ratio.")
    end
    
    return true
  end 
end

# this call registers your script with the OpenStudio SketchUp plug-in
WWRScriptModified.new.registerWithApplication
