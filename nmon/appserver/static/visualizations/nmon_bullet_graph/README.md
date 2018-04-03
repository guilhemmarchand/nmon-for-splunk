# Bullet Graph

Documentation:
http://docs.splunk.com/Documentation/BulletGraph/1.2.0/BulletGraphViz/BulletGraphIntro

## Sample Searches

```
index=_internal | stats count by sourcetype | eval range_low=100, range_med=200, range_high=1000 | fields sourcetype count range_low range_med range_high
```