#  SwiftUI Proportional Stack

This package offers a lightwayight SwiftUI layout that allows the sizing of 
subviews proportionally to its size

![demo image](/demo.png)

## Install

### 1. Swift Package Manager

Add the following to your `Package.swift` file

```swift
dependencies: [
  .package(
    name: "ProportionalStack",
    url: "https://github.com/kemkriszt/ProportionalStack",
    .upToNextMajor(from: "1.0)
  ),

  // Any other dependencies you have...
],
``` 

### 2. Form Xcode

1. Add a package by selecting `File` → `Add Package...` in the Menu bar
2. Search for `https://github.com/kemkriszt/ProportionalStack`

### 3. Manually

Since this is a one file package, you can easily copy the file in your project
and start using the stack view

## Usage

1. Wrap your views in a `ProportionalStack`
2. Define the view proportions using the `.proportion(_:)` modifier

```swift
ProportionalStack(direction: .horizontal) {
    Color.red.proportion(3)
    Color.green
    Color.blue.proportion(2)
}
.frame(width: 300, height: 300)
``` 

The default `proportion` value is 1, the sizes are calculated based on the sum of
all the subview's proportions

### Fixed sized views

`ProportionalStack` also supports views with fixed sizes. For example:

```swift
ProportionalStack(direction: .horizontal) {
    Color.red.proportion(3)
    Color.green.frame(width: 100)
    Color.blue.proportion(2)
}
.frame(width: 300, height: 300)
``` 

In this case, the green view would have a width of 100, and the remaining 200 points 
would be proportionally divided between red and blue 

----

If you want to get in touch, find me on [X](https://x.com/@kkemenes_)
