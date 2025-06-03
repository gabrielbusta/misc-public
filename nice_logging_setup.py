def set_up_logging(opts, args):
    log_fmt = f"%(levelname)s - {args[0]} - %(filename)s - %(funcName)s - %(asctime)s - %(message)s"
    logging.basicConfig(
        filename=opts.log_file,
        format=log_fmt,
    )
    formatter = logging.Formatter(log_fmt)
    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(formatter)
    logging.getLogger().addHandler(stream_handler)
    if opts.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    else:
        logging.getLogger().setLevel(logging.INFO)
