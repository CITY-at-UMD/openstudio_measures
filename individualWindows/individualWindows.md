# Documentation for adding individual windows

## Descriptions
 * This file has the documentation for adding windows to the building.
 * First, we get the number of windows a user wants and also the height and width of each window from the user.
 * Then, we check the inputs for any errors, for example, if the combined width of all the windows is equal or exceeding the length/width of the entire surface, then it is an error. Similarly, if height of the window is equal to or larger than the height of the surface, the input is erroneous.
* Now, for each surface, we calculate the 	center of window vertices.
* First, we check if the number of windows is even or odd and depending on that we calculate the co-ordinates of center vertex for each window for a particular surface.
* Then, we set the co-ordinates of all the four vertices of each window on a surface.
* Then, we check if the surface is aligned in north, east, south or west direction and accordingly we assign the four vertices to each window and draw the window.
* Let us understand this with an example. So, if the user gives inputs as width of window = 3, height of window = 3 and number of windows =3 on each surface of the building.
* Then, we check that multiplication of width of the window and number of windows shall not be equal to or greater than the length and/or width of the surface because then the windows would be outside the boundary of that surface.
* Similarly, we check for the height of the window not to be equal to greater than the height of that surface.
* Now, we start by finding the co-ordinates of center point for each surface and for that we take sum of all x, y and z co-ordinates of the four vertices of that surface and divide than sum by 4 to get the co-ordinates of the center. 
* Now we check whether the number of windows on each surface is odd or even. In our case, it is odd, so then the program would execute that group of statements and get the center points for all the windows.
* Then, we check if the surface is parallel to y- axis or x- axis and depending on that, set the four vertices of each window for that surface.
* Now, to draw the windows, we check if the surface is aligned with north, east, south or west direction, and then draw the window.
* This process of setting the center vertex for the window till drawing the window is repeated till we get all the windows on that surface.
* Similarly, the windows are drawn on other surfaces.

## Visual descriptions
![Building:](https://github.com/buildsci/openstudio_measures/blob/master/individualWindows/1.JPG)
![Image 2:](https://github.com/buildsci/openstudio_measures/blob/master/individualWindows/2.JPG)
![Image 3:](https://github.com/buildsci/openstudio_measures/blob/master/individualWindows/3.JPG)
![Image 4:](https://github.com/buildsci/openstudio_measures/blob/master/individualWindows/4.JPG)
![Image 5:](https://github.com/buildsci/openstudio_measures/blob/master/individualWindows/5.JPG)
![Image 6:](https://github.com/buildsci/openstudio_measures/blob/master/individualWindows/6.JPG)
