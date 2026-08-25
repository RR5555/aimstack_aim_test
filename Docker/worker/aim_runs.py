


from aim import Run


def aim_run():

    run = Run(
        # repo='aim://127.0.0.1:53800', # Should not work
        repo='aim://aim_server:53800', # Should work
        experiment='aim_run'
    )

    # set training hyperparameters
    run['hparams'] = {
        'learning_rate': 0.001,
        'batch_size': 32,
    }

    # log metric
    for i in range(10):
        run.track(i, name='numbers')



def aim_run_fail():

    run = Run(
        repo='aim://127.0.0.1:53800', # Should not work
        # repo='aim://aim_server:53800', # Should work
        experiment='aim_run_fail'
    )

    # set training hyperparameters
    run['hparams'] = {
        'learning_rate': 0.001,
        'batch_size': 32,
    }

    # log metric
    for i in range(10):
        run.track(i, name='numbers')




