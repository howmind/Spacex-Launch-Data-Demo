# spacex_launch

A Flutter project that will display SpaceX data.

## API
API documents are available here:
https://docs.spacexdata.com

## Basic Features:
- Display a list of launches with minimal information
- Ability to sort launches by either launch date or mission name.
- Ability to filter by launch success.
- When a launch is selected display a screen with detailed launch information and the rocket details used for the launch.
    - Data from One Launch endpoint
    - Data from One Rocket endpoint

## More:
- When sorted by launch date, group them by year
- When sorted by mission name, group them by the first alphabet

## Explain the design
- Using three Flutter Plugin Module: http, provider, tuple
- Model Ojbect: Launch, Rocket.
- There are only two pages with loading UI.
- How to update data and UI 
    - Create a LaunchXProvider class which is ChangeNotifier. Use notifyListeners() to update UI and Selector of Provider when request to update data
    - LaunchXProvider has a cache all launch data except details, don't need to request again when you have changed data.
    - Use setState() with local logic change
- Http module to request to json data, use jsonDecode() to map objects, then convert to Launch or Rocket object.
- While each page is launching, request json data in initState() and show Loading Widget.
- Sorted with group
    - Using double list items which odd is group name or shrink and even is actual item.
    - Comparing group information before compare item (example: sort by year firstly,then sort by launch date). The results will be sorted by grounp and items in group also sorted
    - As item builder is invoked in ListView.build, build group name when it is first item in group, others will be shrink by odd index. Otherwise, build actual item by even index.