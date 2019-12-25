function semantic_segmentation_rgb(fileName, sensorType, varName)

    %% Check if input is valid
    if ~isstring(fileName) && ~ischar(fileName)
        error("File name must a string or char array\n")
    end
    
    if ~strcmp(sensorType, "semantic_segmentation_rgb")
       error("Wrong sensor selected\n") 
    end

    if ~isvarname(varName)
        error("Invalid variable name\n")
    end
    
    %% Create a python file 
    file = fopen(strcat(fileName, '.py'), 'w');
    
    % Automatically genrates a python file containing the sensor call back
    % bindings
    fprintf(file, 'import numpy as np\n');
    fprintf(file, '\n');
    fprintf(file, '# Converts the tags to human observable colors\n');
    fprintf(file, '_mapDict = { 0:( 0, 0, 0),			1:(70, 70, 70),		2:(190, 153, 153),\n');
    fprintf(file, '             3:(250, 170, 160),		4:(220, 20, 60),	5:(153, 153, 153),\n');
    fprintf(file, '             6:(157, 234, 50),		7:(128, 64, 128),	8:(244, 35, 232),\n');
    fprintf(file, '             9:(107, 142, 35),		10:(0, 0, 142),		11:(102, 102, 156),\n');
    fprintf(file, '             12:(220, 220, 0)}\n');
    fprintf(file, '\n');
    fprintf(file, 'def _setup_mapping():\n');
    fprintf(file, '    global _mapDict\n');
    fprintf(file, '    global _mapping_array\n');
    fprintf(file, '\n');
    fprintf(file, '    tags = np.array(list(_mapDict.keys()))\n');
    fprintf(file, '    colors = np.array(list(_mapDict.values()))\n');
    fprintf(file, '\n');
    fprintf(file, '    _mapping_array = np.zeros((tags.max()+1, 3), dtype="uint8")\n');
    fprintf(file, '    _mapping_array[tags] = colors\n');
    fprintf(file, '\n');
    
    fprintf(file, 'def bindSensor(sensor):\n');
    fprintf(file, '    _setup_mapping()\n');
    fprintf(file, '    sensor.listen(lambda _image: do_something(_image))\n');
    fprintf(file, '\n');
    fprintf(file, 'def do_something(_image):\n');
    fprintf(file, '    global %s\n', varName);
    fprintf(file, '    global _mapping_array\n');
    fprintf(file, '\n');
    fprintf(file, '    data = np.frombuffer(_image.raw_data, dtype=np.dtype("uint8"))\n');
    fprintf(file, '\n');
    fprintf(file, '    # Get the red channel which has the tags\n');
    fprintf(file, '    data = np.reshape(data, (_image.height, _image.width, 4))\n');
    fprintf(file, '    data = data[:, :, 2]\n');
    fprintf(file, '\n');
    fprintf(file, '    # Map the tags to their respective RGB colors\n');
    fprintf(file, '    data = _mapping_array[data]\n');
    fprintf(file, '\n');
    fprintf(file, '    # Convert the data into MATLAB cast compatible type\n');
    fprintf(file, '    %s = np.ascontiguousarray(data)\n', varName);
    
    fclose(file);

end