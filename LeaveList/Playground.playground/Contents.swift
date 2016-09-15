import UIKit
import Foundation
import CoreLocation
import MapKit
import XCPlayground

/*
 * K-Mean clustering algorithm
 * Wikipedia: https://en.wikipedia.org/wiki/K-means_clustering
 * and some visualisation http://util.io/k-means
 */


// Centroid data structure
struct Centroid {
    var center: CLLocation // Center of this centroid
    var points: [CLLocation] // Points near this centroid
}

// K-Mean clustering initial K centroids definition and distribution
func initializeCentroids(locations: [CLLocation], maxDistance: CLLocationDistance) -> [Centroid] {
    var centroids = [Centroid]()
    
    // Find a location far enough from all previous centroids and add it into a list of centroids
    for location in locations {
        var foundCentroid = false
        
        for centroid in centroids {
            let distance = centroid.center.distanceFromLocation(location)
            
            if distance <= maxDistance {
                foundCentroid = true
                break
            }
        }
        
        if !foundCentroid {
            centroids.append(Centroid(center: location, points: [CLLocation]()))
        }
    }
    
    return centroids
}

// K-Mean clustering implementation
func clusterLocations(locations: [CLLocation], maxDistance: CLLocationDistance) -> [Centroid] {
    var centroids = initializeCentroids(locations, maxDistance: maxDistance)
    var centerMoveDist: CLLocationDistance = 0.0
    
    repeat {
        var newCentroids = [Centroid]()
        
        // Clone old centroid list into new centroid list
        for centroid in centroids {
            newCentroids.append(Centroid(center: centroid.center, points: [CLLocation]()))
        }
        
        // For each location find nearest centroid and associate location with this centroid
        for location in locations {
            for i in 0..<newCentroids.count {
                let distance = newCentroids[i].center.distanceFromLocation(location)
                
                if distance < maxDistance {
                    newCentroids[i].points.append(location)
                    break
                }
            }
        }
        
        // Adjust centroid centers based on nearest locations associated with this centroid
        for i in 0..<newCentroids.count {
            newCentroids[i].center = CLLocation.centroidForLocations(newCentroids[i].points)
        }
        
        centerMoveDist = 0
        
        // Calculate distance from old centroid locations and new centroid locations
        for i in 0..<newCentroids.count {
            centerMoveDist = newCentroids[i].center.distanceFromLocation(centroids[i].center)
            
            if centerMoveDist > maxDistance { break }
        }
        
        // Update current centroid list
        centroids = newCentroids
        
    } while centerMoveDist > maxDistance // Check if distance difference small enough to stop
    
    return centroids
}

extension CLLocation {
    class func centroidForLocations(locations: [CLLocation]) -> CLLocation {
        var latitude: CLLocationDegrees = 0
        var longitude: CLLocationDegrees = 0
        
        for location in locations {
            let coordinate = location.coordinate
            
            latitude += coordinate.latitude;
            longitude += coordinate.longitude
        }
        
        return CLLocation(latitude: latitude / CLLocationDistance(locations.count),
                          longitude: longitude / CLLocationDistance(locations.count))
    }
    
    func locationWithBearing(bearing:Double, distance:CLLocationDistance) -> CLLocation {
        let earthRadius = 6372797.6 // earth radius in meters
        let distRadians = distance / earthRadius
        let origin = self.coordinate
        
        let lat1 = origin.latitude * M_PI / 180
        let lon1 = origin.longitude * M_PI / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocation(latitude: lat2 * 180 / M_PI, longitude: lon2 * 180 / M_PI)
    }
}

class ColoredAnnotation: MKPointAnnotation {
    private var pinColor: UIColor
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}

// Create a map view
let mapView = MKMapView(frame: CGRect( x:0, y:0, width:800, height:800))

// Create an initial point (Marina Bay Sands)
let initialPoint = CLLocation(latitude: 1.2832185, longitude: 103.8581184)

// Create and populate a visible region on the map
var region = MKCoordinateRegion()

region.center.latitude = initialPoint.coordinate.latitude
region.center.longitude = initialPoint.coordinate.longitude

// Span defines the zoom
let delta = 0.01

region.span.latitudeDelta = delta
region.span.longitudeDelta = delta

// inform the mapView of these edits
mapView.setRegion( region, animated: false )

protocol MapRenderable {
    func renderInView(mapView: MKMapView)
}

class Renderer: NSObject, MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            let colorPointAnnotation = annotation as! ColoredAnnotation
            pinView?.pinTintColor = colorPointAnnotation.pinColor
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
}

class LocationsRenderer: Renderer, MapRenderable {
    var locations: [CLLocation] = []
    var color: UIColor?
    
    func renderInView(mapView: MKMapView) {
        let colors: [UIColor] = [.blueColor(), .magentaColor(), .brownColor(), .greenColor()]
        var pinColor = UIColor.blueColor()
        
        if let color = color { pinColor = color } else {
            pinColor = colors[Int(arc4random()) % colors.count]
        }
        
        for location in locations {
            let annotation = ColoredAnnotation(pinColor: pinColor)
            
            annotation.coordinate = location.coordinate
            
            mapView.addAnnotation(annotation)
        }
    }
}

class CentroidsRenderer: Renderer, MapRenderable {
    var centroids: [Centroid] = []
    
    func renderInView(mapView: MKMapView) {
        let colors: [UIColor] = [.blackColor(), .whiteColor(), .orangeColor(), .purpleColor()]
        
        mapView.delegate = self
        
        for i in 0..<centroids.count {
            let centroid = centroids[i]
            let color = colors[i % colors.count]
            
            let annotation = ColoredAnnotation(pinColor: color)
            
            annotation.coordinate = centroid.center.coordinate
            annotation.title = "centroid\(i)"
            
            mapView.addAnnotation(annotation)
            
            let locationsRenderer = LocationsRenderer()
            
            locationsRenderer.locations = centroid.points
            locationsRenderer.color = colors[(i + 1) % colors.count]
            locationsRenderer.renderInView(mapView)
        }
    }
}

// List of all locations
var locations = [CLLocation]()

// List of all centroids
var centroidLocations = [CLLocation]()

centroidLocations.append(initialPoint)

let maxDistance: CLLocationDistance = 200.0 // meters

// Generate random centroids
for i in 0..<3 {
    let angle = Double(arc4random() % 360) * 180.0 / M_PI
    let distance = 500 + Double(arc4random() % 100)
    let location = initialPoint.locationWithBearing(angle, distance: distance)
    
    centroidLocations.append(location)
}

// Generate random set of locations near each centroid
for centroid in centroidLocations {
    for i in 0..<10 {
        let angle = Double(arc4random() % 360) * 180.0 / M_PI
        let distance = Double(arc4random() % 100)
        let location = centroid.locationWithBearing(angle, distance: distance)
        
        locations.append(location)
    }
}

let locationsRenderer = LocationsRenderer()
locationsRenderer.locations = locations

//locationsRenderer.renderInView(mapView)

let centroids = clusterLocations(locations, maxDistance: maxDistance)

let centroidsRenderer = CentroidsRenderer()
centroidsRenderer.centroids = centroids

print(centroids.count)
print(centroids[0].points.count)

centroidsRenderer.renderInView(mapView)

XCPlaygroundPage.currentPage.liveView = mapView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
