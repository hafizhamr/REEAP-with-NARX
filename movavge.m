function result = movavge(theta, windowWidth)
    kernel = ones(windowWidth, 1) / windowWidth;
    result = filtfilt(kernel, 1, theta);
end