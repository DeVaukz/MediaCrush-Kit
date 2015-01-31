MediaCrushKit
=============

**Notice**: MediaCrush has shut down. The API only exists if you are running your own instance, or using a third party instance.

MediaCrushKit is a Cocoa framework for interacting with the [MediaCrush API](https://mediacru.sh/docs/api).  It's built atop [AFNetworking](https://github.com/AFNetworking/AFNetworking),
[Mantle](https://github.com/MantleFramework/Mantle), and
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

## MediaCrush API Notes

As you evaluate the usage of MediaCrushKit and the MediaCrush service in your application, be aware of the following:

- The MediaCrush service does not have user accounts.  This is due to the creator's staunch support of end user [privacy](https://mediacru.sh/serious).  MediaCrush aims to store as little uniquely identifying data as possible.

- A hash of the uploader's IP address is used to determine ownership of media blobs (including albums).  An edit or deletion operation will fail if the requester's IP address does not match the uploader's IP address.  A [revision to the API](https://github.com/MediaCrush/MediaCrush/tree/APIv2) is in progress which will address this.

Finally, if your usage of the MediaCrush API will direct large amounts of traffic to the [mediacru.sh](https://mediacru.sh) servers, the creators of MediaCrush would appreciate a [donation](https://mediacru.sh/donate) to offset the cost of running the service.

## Making Requests

In order to begin interacting with the API, you must instantiate an
[MCKClient](Source/MCKClient.h).  Instantiating an MCKClient requires you provide an [MCKServer](Source/Server/MCKServer.h) configured for the MediaCrush server you wish to communicate with.  Call the `+defaultServer` method to create an `MCKServer` configured for communicating with [mediacru.sh](https://mediacru.sh).

After we've got a client, we can start fetching data. Each request method on
`MCKClient` returns
a [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) signal, which
is kind of like a [future or
promise](http://en.wikipedia.org/wiki/Futures_and_promises):

```objc
// Prepares a request that will load the files, represented by MCKFile
// objects, for the provided IDs.
//
// Note that the request is not actually _sent_ until you use one of the
// -subscribe… methods below.
RACSignal *request = [client fetchFilesWithIDs:@[@"SomeId"]];
```
However, you don't need a deep understanding of RAC to use MediaCrushKit. There are
just a few basic operations to be aware of.

### Receiving results one-by-one

It often makes sense to handle each result object independently, so you can
spread any processing out instead of doing it all at once:

```objc
// This method actually kicks off the request, handling any results using the
// blocks below.
[request subscribeNext:^(MCKFile *file) {
    // This block is invoked for _each_ result received, so you can deal with
    // them one-by-one as they arrive.
} error:^(NSError *error) {
    // Invoked when an error occurs.
    //
    // Your `next` and `completed` blocks won't be invoked after this point.
} completed:^{
    // Invoked when the request completes and we've received/processed all the
    // results.
    //
    // Your `next` and `error` blocks won't be invoked after this point.
}];
```

### Receiving all results at once

If you can't do anything until you have _all_ of the results, you can "collect"
them into a single array:

```objc
[[request collect] subscribeNext:^(NSArray *files) {
    // Thanks to -collect, this block is invoked after the request completes,
    // with _all_ the results that were received.
} error:^(NSError *error) {
    // Invoked when an error occurs. You won't receive any results if this
    // happens.
}];
```

### Receiving results on the main thread

The blocks in the above examples will be invoked in the background, to avoid
slowing down the main thread. However, if you want to run UI code, you shouldn't
do it in the background, so you must "deliver" results to the main thread
instead:

```objc
[[request deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(MCKFile *file) {
    // ...
} error:^(NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                    message:@"Something went wrong."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];
} completed:^{
    [self.tableView reloadData];
}];
```

### Canceling a request

All of the `-subscribe…` methods actually return
a [RACDisposable](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoaFramework/ReactiveCocoa/RACDisposable.h)
object. Most of the time, you don't need it, but you can hold onto it if you
want to cancel requests:

```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    RACDisposable *disposable = [[[[self.client
        fetchFilesWithIDs:@[@"SomeId"]]
        collect]
        deliverOn:RACScheduler.mainThreadScheduler]
        subscribeNext:^(NSArray *files) {
            [self addTableViewRowsForRepositories:files];
        } error:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                            message:@"Something went wrong."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
            [alert show];
        }];

    // Save the disposable into a `strong` property, so we can access it later.
    self.filesDisposable = disposable;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Cancels the request for the files if it's still in progress. If the
    // request already terminated, nothing happens.
    [self.filesDisposable dispose];
}
```

## License

MediaCrushKit is released under the MIT license. See
[LICENSE.md](https://github.com/DeVaukz/MediaCrushKit/blob/master/LICENSE).
