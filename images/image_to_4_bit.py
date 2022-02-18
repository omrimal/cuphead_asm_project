from importlib.resources import path
import cv2
import os
import numpy as np
import matplotlib.pyplot as plt

path = "C:/Users/משתמש/Desktop/tmp/cuphead_asm_project/images/Flower_Boss/pose2.png"

if os.path.exists(path):
    img = cv2.imread(path)

    #Convert the image to grayscale
    gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    plt.imshow(gray_img, cmap='gray')