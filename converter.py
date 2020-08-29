import logging
import multiprocessing as mp
import time

from jawiki import converter


class FileProcessor:
    def __init__(self):
        logger = mp.log_to_stderr()
        logger.setLevel(logging.INFO)
        self.logger = logger

    def run(self, srcfname: str, worker, dstfname: str, writer):
        t0 = time.time()
        results_pool = self.read(srcfname, worker)
        self.write(dstfname, results_pool, writer)
        self.logger.info(f"Converted in {str(time.time() - t0)} seconds")

    def read(self, srcfname, worker):
        numprocs = mp.cpu_count()
        pool = mp.Pool(processes=numprocs)
        results_pool = []
        with open(srcfname, 'r', encoding='utf-8') as fp:
            buf = []
            for line in fp:
                buf.append(line)
                if len(buf) > 20000:
                    results_pool.append(pool.apply_async(worker, args=(buf,)))
                    buf = []
            if len(buf) > 0:
                results_pool.append(pool.apply_async(worker, args=(buf,)))
        return results_pool

    def write(self, dstfname, results_pool, writer):
        with open(dstfname, 'w', encoding='utf-8') as ofh:
            finished_cnt = 0
            pool_size = len(results_pool)
            while len(results_pool) > 0:
                for r in results_pool:
                    if r.ready():
                        results = r.get()
                        for result in results:
                            writer(result)
                        finished_cnt += 1
                        results_pool.remove(r)
                time.sleep(0.1)
                self.logger.info(f"{finished_cnt}/{pool_size}")


def converter_worker(chunk):
    jawiki_converter = converter.Converter()
    results = []
    for line in chunk:
        splitted = line.strip().split("\t")
        if len(splitted) != 3:
            continue
        title, kanji, yomi = splitted
        kanji, yomi = jawiki_converter.convert(kanji, yomi)
        if len(yomi) > 0:
            results.append([kanji, yomi])
    return results


if __name__ == '__main__':
    ofh = open('dat/converted.tsv', 'w', encoding='utf-8')


    def converter_writer(result):
        kanji, yomi = result
        ofh.write(f"{kanji}\t{yomi}\n")


    file_processor = FileProcessor()
    file_processor.run(
        'dat/pre_validated.tsv', converter_worker,
        'dat/converted.tsv', converter_writer
    )
