This is a record of questions about REDCap that came up for us as we were working on this project.

## Meeting: TBD

In attendance: 

- **Is there some venue we should be thinking about for publishing/presenting/sharing this approach?**
- **In our weekly "Your progress on the [flower] pathway" alerts, e.g. `[jasmine_complete][last-instance] <> '2'` works but `[jasmine_complete][current-instance] <> '2'` doesn't. Why?**
- **Are we crazy to have separate alerts for each week's inactive nudge? In testing, records that newly became eligible weren't added to the list to be notified (records that stopped being eligible were correctly removed, though).**


## Meeting: 2023-08-16

In attendance: Rose H, Elizabeth, Lara

- **We can't get the alert preview to show the piped fields for module status (e.g. Not Started, Started, Done!) for the weekly "Your progress on the [flower] pathway" alerts.** Previews are unreliable! Instead check the notification log for alerts. You can see scheduled alerts in advance there. Previews throughout REDCap are a little suss, Lara said she doesn't know of any specific problems with alert previews, but she's overall distrustful of previews and prefers the logs. 
- **When we tested the pathway ASIs in May, the links worked as expected, but now they don't.** The links were badly formatted. We had `[survey-link:Progress on the $pathway pathway][new-instance]` in `create_asi.sh` which resolves to e.g. `[survey-link:Progress on the aster pathway][new-instance]`, but it should have been `[survey-link:$pathwayunderscore:Progress on the $pathway pathway][new-instance]` resolving to `[survey-link:$aster_pathway:Progress on the aster pathway][new-instance]`. The link probably should never have worked in the first place, but it did because we were unintentionally taking advantage of a bug in how the repeating instrument ASIs were working. REDCap fixed bugs, including apparently whatever we were using, in the update on Aug 7. Lara said that ASIs for repeating instruments are actually a pretty new feature and maybe not stable yet (repeating instruments themselves are not new; before ASIs were available alerts were the workaround). 
- **Is there something we could have done to test this better?** Lara can add us to the list of folks who get early access to REDCap updates for testing! Yay! The dart email should get a ping when that happens. 
