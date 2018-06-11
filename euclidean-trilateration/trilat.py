#refer to the trilateration wikipedia page
#sudo pip install numpy
import math
import numpy

def trilat(hubNum, unUsed, coords):
    #Testing: coords = [11,60,61], [12, 35  ,37], [13, 84  ,85]
    result = f_trilateration(coords[0][0],coords[0][1],coords[0][2],
        coords[1][0],coords[1][1],coords[1][2],
        coords[2][0],coords[2][1],coords[2][2])
    
    strA = "\n\n [%d Hubs Detected] " % (hubNum)
    strB = "Error Margin: (%f m) " % (math.fabs(result[2]))
    strC = strA + strB
    strD = "\n Calculated Coordinate: (%f, %f)--------------\n\n" % (result[0],result[1])

    return [strC, strD]

def f_trilateration(p_LatA, p_LngA, p_DistA, p_LatB, p_LngB, p_DistB, p_LatC, p_LngC, p_DistC):
    l_P1 = numpy.array([p_LatA, p_LngA, p_DistA])
    l_P2 = numpy.array([p_LatB, p_LngB, p_DistB])
    l_P3 = numpy.array([p_LatC, p_LngC, p_DistC])

    #transform to get circle 1 at origin
    #transform to get circle 2 on x axis
    l_ex = (l_P2 - l_P1)/(numpy.linalg.norm(l_P2 - l_P1))
    l_i = numpy.dot(l_ex, l_P3 - l_P1)
    l_ey = (l_P3 - l_P1 - l_i*l_ex)/(numpy.linalg.norm(l_P3 - l_P1 - l_i*l_ex))
    l_ez = numpy.cross(l_ex,l_ey)
    l_d = numpy.linalg.norm(l_P2 - l_P1)
    l_j = numpy.dot(l_ey, l_P3 - l_P1)

    #plug and chug using above values
    l_x = (pow(p_DistA,2) - pow(p_DistB,2) + pow(l_d,2))/(2*l_d)
    l_y = ((pow(p_DistA,2) - pow(p_DistC,2) + pow(l_i,2) + pow(l_j,2))/(2*l_j)) - ((l_i/l_j)*l_x)
    l_z = numpy.sqrt(abs(pow(p_DistA,2) - pow(l_x,2) - pow(l_y,2)))
    
    #l_triPt is an array with x,y,z of trilateration point
    l_triPt = l_P1 + l_x*l_ex + l_y*l_ey + l_z*l_ez
    return l_triPt