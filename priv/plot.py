import matplotlib.pyplot as plt
import numpy as np
import json

# plt.plot([1, 2, 3, 4])
# plt.ylabel('some numbers')
# plt.show()

with open("./priv/results.json", "r") as f:
	results = json.loads(f.read())

for r in results:
	result = results[r]
	print(result)

	result_by_n = {}
	for item in result:
		if item["n"] not in result_by_n:
			result_by_n[item["n"]] = [[], []]

		result_by_n[item["n"]][0].append(str(item["m"]))
		result_by_n[item["n"]][1].append(item["allowed_ms"])

	print(result_by_n)

	si = 1
	plt.figure()
	for n in result_by_n:
		plt.subplot(210+si)
		si += 1

		plt.bar(result_by_n[n][0], result_by_n[n][1])
		plt.ylabel('average delay (ms)')
		plt.xlabel('number of policies')
		plt.title("%d attributes per policy" % n)
		plt.ylim(0)

	plt.subplots_adjust(hspace=0.6)
	# plt.show()
	plt.savefig('./priv/%s.png' % r)
