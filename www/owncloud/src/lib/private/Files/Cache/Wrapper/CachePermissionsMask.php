<?php
/**
 * @author Morris Jobke <hey@morrisjobke.de>
 * @author Robin Appelman <icewind@owncloud.com>
 *
 * @copyright Copyright (c) 2016, ownCloud GmbH.
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

namespace OC\Files\Cache\Wrapper;

class CachePermissionsMask extends CacheWrapper {
	/**
	 * @var int
	 */
	protected $mask;

	/**
	 * @param \OCP\Files\Cache\ICache $cache
	 * @param int $mask
	 */
	public function __construct($cache, $mask) {
		parent::__construct($cache);
		$this->mask = $mask;
	}

	protected function formatCacheEntry($entry) {
		if (isset($entry['permissions'])) {
			$entry['permissions'] &= $this->mask;
		}
		return $entry;
	}
}
